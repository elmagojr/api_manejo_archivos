const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const ODBC = require("odbc");
const bcrypt = require('bcrypt');
const connectionString = 'DSN=SISC';


const clave_secreta = "file_upload_secret";
function EncritarPass(pass) {
    const hash = bcrypt.hashSync(pass, 10); // 10 es el número de rondas de sal  
    return hash;
}

function verificaToken(req, res, next) {
    const token = req.headers['authorization']; // el nombre del header 
    if (!token) {
        return res.status(401).json({ message: 'No se proporcionó token' });
    }
    const tokenPart = token.split(' ')[1]; // Extraer el token del formato "Bearer <token>"
    jwt.verify(tokenPart, clave_secreta, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Token inválido' });
        }
        req.user = decoded; //el obejto que respuesta, nombre de usuario, id permison etc
        next();
    });
}

function VerificaPassword(password, hash) {
    return bcrypt.compareSync(password, hash);
}

router.post('/login', verificaToken, async (req, res) => {
    const { username, password } = req.body;
    //verifica que los datos en bd sean los mismos
 
    //deserializar token
    try {
        const connection = await ODBC.connect(connectionString);
        const token_bd = await connection.query(`SELECT token_id FROM "DBA"."USUARIOS_HUELLAS" WHERE NOMBRE_USR =?`, [username]); //este token es el que guarda las credenciales del usr
        await connection.close();
        const decoded = jwt.verify(token_bd[0]["token_id"], clave_secreta);
        if (decoded.username === username && VerificaPassword(password, decoded.new_pass)) {
            // Login exitoso
            const newToken = jwt.sign({ username, new_pass: decoded.new_pass }, clave_secreta);//este token es el que debe guardar en local
            //console.log('Payload válido:', decoded);
            res.json({ estado:1,id_usr:decoded.id, user:decoded.username, token: newToken,message: 'ok' });
        }

    } catch (error) {
        console.log('error consulta login: ' + error);
        res.status(401).json({ estado:0, message: 'Credenciales inválidas' });
    }


});


router.post('/registro', async (req, res) => {
    const { id, username, password } = req.body;
    var tokenGenerado = "";
    const new_pass = EncritarPass(password);

    jwt.sign({ id, username, new_pass }, clave_secreta, (err, token) => {
        if (err) {
            return res.status(500).json({ message: 'Error al generar token' });
        }
        tokenGenerado = token;
        //res.json({ message: `ok`, token });
    });
    //registro en la bd
    try {
        const connection = await ODBC.connect(connectionString);
        //HAY QUE AGREGAR EL ID DEL ROL
        const result = await connection.query(`CALL "DBA"."SP_USRS_HUELLAS"("@TIPO" = 3,"@ID_ROLHUE" = '1',"@NOMBRE_ROLHUE" = ?,"@PERMISOS_ROLHUE" = ?,"@USR_ROL" = ?)`, [username, tokenGenerado, username]);
        const ID_USR = await connection.query(`SELECT ID_USR FROM "DBA"."USUARIOS_HUELLAS" WHERE NOMBRE_USR = ?`, [username]);
        await connection.close();

        if (result[0]["@@ESTADO"] < 0) {
            return res.status(400).json({ estado: result[0]["@@ESTADO"],  message: 'Usuario ya existe' });
        }
        res.json({ estado: result[0]["@@ESTADO"], id_usr: ID_USR[0]["ID_USR"], user: username, token: tokenGenerado, message: "ok" });//devuele un nuemero
    } catch (error) {
        console.error('❌ Error al ejecutar consulta:', error);
        res.status(500).send('Error al consultar la base de datos');
    }
});

router.post("/api/logout", (req, res) => {
    res.json({ message: "Logout exitoso, borrar en metodo de guardado" });
});

module.exports = router;