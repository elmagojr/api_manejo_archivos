app.post('/cargar',  (req, res)=>{
    const uploadDir = path.resolve('archivos_cargados');
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir);
    }
    const storage = multer.diskStorage({
        destination: (req, file, cb)=>{
            const identidad = req.body.temp_identidad;
            const usr_dir = path.join(uploadDir, identidad);
            console.log('id multer'+identidad);
            if (!fs.existsSync(usr_dir)) {
                fs.mkdirSync(usr_dir, { recursive: true });
            }
            cb(null, usr_dir);
        },
        filename: (req, file, cb)=>{
            const nombre = req.body.temp_nombre || 'desconocido';
            const nombreFinal = `${file.originalname}-${Date.now()}-${nombre}`;
            cb(null, nombreFinal);
        }
    })


    const subidaArchivo = multer({
        storage:storage,
        limits: {
            fileSize: 5 * 1024 * 1024 // 5 megas
          }
    }).single('archivo');
    subidaArchivo(req, res, (err) => {
        if (err) {
            console.error('Error al subir archivo:', err);
            return res.status(500).send('Error al subir archivo');
        }

        if (!req.file) {
            return res.status(400).send('No se recibió ningún archivo');
        }

        res.send('Archivo subido exitosamente');
    });

});






/* 
******************************************************************** */

document.addEventListener('DOMContentLoaded',()=>{
    const FORMULARIO = document.getElementById('formulario_NOEXISTE');
    FORMULARIO.addEventListener('submit', async (event)=>{
       event.preventDefault();
       const archivo = document.getElementById('archivo').files[0];
       const identidad = document.getElementById('temp_identidad').value;
       const nombre = document.getElementById('temp_nombre').value;
       
      // const archivo = document.getElementById('archivo').files[0];
   
       if (!archivo) {
           alerta("No se ha escogido un archivo. Seleccion uno");
           return;
       }
   
   /*     const fromdata = new FormData();
       fromdata.append('archivo', archivo);
       fromdata.append('temp_identidad', identidad);
       fromdata.append('temp_nombre', nombre);
       try {
   
           for (const pair of fromdata.entries()) {
               console.log(`${pair[0]}: ${pair[1]}`);
           }
           
           const resp = await fetch('/cargar', {
               method:'POST',
               body:fromdata
           });
           const MENSAJE = await resp.text();
           alerta(MENSAJE);
           FORMULARIO.reset();
       } catch (error) {
           console.error('Error al subir el documento'. error);
           alerta('Error al subir archivo')
       } */
    })
   })


   destination: (req, file, cb) => {
    const nombrEDirectorio = req.query.nombre; // 🔥
    const uploadpath = path.join(dir_principal, nombrEDirectorio);

    if (!fs.existsSync(uploadpath)) {
        return cb(new Error("El directorio no existe"));
    }

    cb(null, uploadpath);
}




app.post('/subir_archivo', (req, res) => {
    upload.single('archivo')(req, res, function (err) {
        if (err) {
            if (err.code === 'LIMIT_FILE_SIZE') {
                return res.status(400).json({ mensaje: 'El archivo excede el tamaño permitido (5 MB)' });
            }
            return res.status(500).json({ mensaje: 'Error al subir archivo', error: err.message });
        }

        if (!req.file) {
            return res.status(400).json({ mensaje: 'No se recibió archivo alguno' });
        }

        res.json({ mensaje: 'Archivo cargado con éxito 😉' });
    });
});







//////////////////////////////////////debounce

 function debounce(func, delay) {
    let timeout;
    return function (...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), delay);
    };
  }

(function() {
    const input = document.getElementById("searchInput");

    input.addEventListener("input", (function() {
      let timeout;

      return function() {
        clearTimeout(timeout);

        timeout = setTimeout(() => {
          const filtro = input.value.toLowerCase();
          const filas = document.querySelectorAll("#miTabla tbody tr");

          filas.forEach(fila => {
            const textoFila = fila.textContent.toLowerCase();
            fila.style.display = textoFila.includes(filtro) ? "" : "none";
          });
        }, 300);
      };
    })());
  })();