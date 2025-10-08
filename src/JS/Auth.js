const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const ODBC = require("odbc");
const bcrypt = require('bcrypt');
const { constants } = require('fs/promises');
const { decode } = require('punycode');
const connectionString = 'DSN=SISC';


const clave_secreta = "file_upload_secret";
function EncritarPass(pass) {
    const hash = bcrypt.hashSync(pass, 10); // 10 es el número de rondas de sal  
    return hash;
}

function verificaToken(req, res, next) {
    const token = req.headers['authorization']; // el nombre del header    
    if (!token) {
        return res.status(403).json({ valido:false, message: 'No se proporcionó token' });
    } 
    const tokenPart = token.split(' ')[1]; // Extraer el token del formato "Bearer <token>"
    
    try {
        const decoded = jwt.verify(tokenPart, clave_secreta)
        req.username = decoded.username
        req.id_usr = decoded.id_usr
        next();

   
    } catch (error) {
         return res.status(403).json({ valido:false, message: 'Token invalido o expirado' });
    }
    

}



function VerificaPassword(password, hash) {
    return bcrypt.compareSync(password, hash);
}

router.post('/login', async (req, res) => {
    const { username, password } = req.body;
    //verifica que los datos en bd sean los mismos

    //deserializar token
    try {
        const connection = await ODBC.connect(connectionString);
        const pass_db = await connection.query(`SELECT id_usr,nombre_usr,token_id FROM "DBA"."USUARIOS_HUELLAS" WHERE NOMBRE_USR =?`, [username]); //este token es el que guarda las credenciales del usr
        await connection.close(); 
        if (pass_db.length === 0) {
            return res.status(401).json({ estado: 0, message: 'Usuario o contraseña incorrectos' });
        }
        


        if (pass_db[0]["nombre_usr"] === username && VerificaPassword(password, pass_db[0]["token_id"])) {

            // Login exitoso
            const newToken = jwt.sign({ id_usr:pass_db[0]["id_usr"], username }, clave_secreta, { expiresIn: '2min' });//este token es el que debe guardar en local
            //console.log('Payload válido:', decoded);
            res.json({ estado: 1, id_usr: pass_db[0]["id_usr"], user: pass_db[0]["nombre_usr"], token: newToken, message: 'ok' });
        } else {
            return res.status(401).json({ estado: 0, message: 'Usuario o contraseña incorrectos' });
        }

    } catch (error) {
        console.log('error consulta login: ' + error);
        res.status(401).json({ estado: 0, message: 'Credenciales inválidas' });
    }


});

router.get('/VerificaToken', verificaToken, async (req, res) => {  
 res.json({valido:true,message: 'ok' })
});

router.post('/registro', async (req, res) => {
    const { id, username, password } = req.body;
    var tokenGenerado = "";
    const new_pass = EncritarPass(password);
   
    //registro en la bd
    try {
        const connection = await ODBC.connect(connectionString);
        //HAY QUE AGREGAR EL ID DEL ROL
        const result = await connection.query(`CALL "DBA"."SP_USRS_HUELLAS"("@TIPO" = 3,"@ID_ROLHUE" = '1',"@NOMBRE_ROLHUE" = ?,"@PERMISOS_ROLHUE" = ?,"@USR_ROL" = ?)`, [username, new_pass, username]);
        const ID_USR = await connection.query(`SELECT ID_USR FROM "DBA"."USUARIOS_HUELLAS" WHERE NOMBRE_USR = ?`, [username]);
        await connection.close();

        if (result[0]["@@ESTADO"] < 0) {
            return res.status(400).json({ estado: result[0]["@@ESTADO"], message: 'Usuario ya existe' });
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