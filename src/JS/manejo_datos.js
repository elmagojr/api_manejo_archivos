



function alerta(texto) {
    alert(texto);
}
function ASIGNA_DATA(data) {
    
    if (data.length > 0) {
        document.getElementById('btn_subir').disabled=false;
        if (data[0].COOP_SEXO===0) { 
            data[0].COOP_SEXO='Masculino';
        } 
        else if (data[0].COOP_SEXO===1) {
            data[0].COOP_SEXO='Femenino';
        } 
        else {
            data[0].COOP_SEXO='No aplica';
        }
        switch (data[0].COOP_ESTADO_CIVIL) {
            case 0:
                data[0].COOP_ESTADO_CIVIL='Soltero(a)';   
                break;
                case 1:
                    data[0].COOP_ESTADO_CIVIL='Casado(a)';   
                    break;  
                    case 2:
                        data[0].COOP_ESTADO_CIVIL='Unión Libre';   
                        break;    
                        case 0:
                            data[0].COOP_ESTADO_CIVIL='Viudo(a)';   
                            break;          
            default:
                break;
        }
        
        document.getElementById('coop_nombre').value = data[0].COOP_NOMBRE;
        document.getElementById('temp_nombre').value = data[0].COOP_NOMBRE;//es el input oculto temporal
        document.getElementById('coop_codigo').value = data[0].COOP_CODIGO;
        document.getElementById('coop_Identidad').value = data[0].COOP_IDENTIDAD;
        document.getElementById('temp_identidad').value = data[0].COOP_IDENTIDAD;//es el input oculto temporal
        document.getElementById('coop_Genero').textContent  = data[0].COOP_SEXO;
        document.getElementById('coop_ec').textContent = data[0].COOP_ESTADO_CIVIL;
        document.getElementById('coop_Telefono').value = data[0].COOP_TEL2;
        document.getElementById('coop_email').value = data[0].COOP_CORREO_ELEC;


        
    } else {
  
    }
}
function mostrarCargando(mostrar) {
    if (mostrar) {
        document.getElementById('pantallaCargando').style.display = 'flex';
    } else {
        document.getElementById('pantallaCargando').style.display = 'none';
    }
  
  }
  
  
 function debounce(func, delay) {
    let timeout;
    return function (...args) {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, args), delay);
    };
  }



document.getElementById("txt_busqueda").addEventListener("input", debounce(function () {
    const filtro = document.getElementById("txt_busqueda").value.toLowerCase();
    const filas = document.querySelectorAll("#tbl_afiliado tbody tr");

    filas.forEach(fila => {
        const textoFila = fila.textContent.toLowerCase();
        fila.style.display = textoFila.includes(filtro) ? "" : "none";
    });
}, 500));

async function TraeTodosLosAfiliados() {   
    mostrarCargando(true);
    const tabla_afiliados = document.getElementById('tbl_afiliado').querySelector('tbody');
    const respuesta = await fetch(`/api/allcoop`);

    if (!respuesta.ok) {
        alerta("No se encuentran afilaidos")
        mostrarCargando(false);
    } 
    const datos = await respuesta.json();
    if (datos.length===0) {
        alerta("Se obtuvo respuesta, pero no hay datos que mostrar")
        mostrarCargando(false);     
    } 
    tabla_afiliados.innerHTML = datos.length ? datos.map(D=>`
                <tr>
                    <td>
                        <a target="" class="btn btn-primary btn-sm" href="/?id=${D.coop_codigo} " role=""><i class="ri-arrow-right-long-fill"></i></a>
                    </td>                 
                    <td>${D.coop_codigo}</td>
                    <td>${D.coop_identidad}</td>
                    <td>${D.coop_nombre}</td>
                    <td>${D.coop_rtn}</td>
                    <td>${D.coop_codigo_ant}</td>                 
                </tr> 
        
        `).join(''):'<tr><td>No hay datos</td></tr>'
   mostrarCargando(false);
//datos.map(D=>
}


function btn_load(load) {
    if (load) {
        btn.disabled = load;
        spinner.classList.remove('d-none');
        texto.textContent = 'Subiendo...';
    } else {
        btn.disabled = load;
        spinner.classList.add('d-none');
        texto.textContent = 'Subir archivo';
    }
}
function load_data(tipo) {
    //document.addEventListener('DOMContentLoaded',()=>{
        mostrarCargando(true);   
        const params = new URLSearchParams(window.location.search);
        var id=''
        if (tipo===1) {
             id = params.get('id');
        } else {
             id =document.getElementById('coop').value;//aca se pone en ele cuadr de busqueda
        }
        
        if (id) {
     
            fetch(`/api/coop?id=${id}`).then(response=>response.json()).then(data =>{
                if (data.length > 0) {
                   ASIGNA_DATA(data);     
                   carga_archivos()        
                } else { 
                    alerta("No se encontró al afiliado")
                }
            }).catch(err=>{
                alerta('Error al cargar datos [BD]: '+err.message)
                console.error('Error al cargar datos: ',err);
            })
            
        } 
        mostrarCargando(false);
    //})
}


const btn = document.getElementById('btnSubir');
const spinner = document.getElementById('spinner');
const texto = document.getElementById('textoBtn');


async function crearYSubir() {
    event.preventDefault();
    const btn_subir = document.getElementById('btn_subir');
    const formulario = document.getElementById('formulario');
    const archivo = document.getElementById('archivo').files[0];
    const identidad = document.getElementById('temp_identidad').value;
    const nombre = document.getElementById('temp_nombre').value;  
    const tipoDoc = document.getElementById('Stipo').value; 
    const SIZE_MAX =5;
    mostrarCargando(true)
    //btn_load(true);
    //btn_subir.disabled =true;
    if (!archivo) {
        alerta("No se ha escogido un archivo. Seleccion uno");
        mostrarCargando(false)
        return;
    } else {
        if (tipoDoc==0) {
            alerta("Seleccione un tipo de documento");
            mostrarCargando(false)
            return;
        }
        if (!identidad) {
            alerta("Busque una persona valida a quién le pertenezca este documento");
            mostrarCargando(false)
            return;
        }

        const fileSize = archivo.size;
        if (fileSize >SIZE_MAX * 1024 * 1024) {
            alerta("Archivo excede el tamaño minimo [5MB]")
            mostrarCargando(false);
            return;    
        }        
       
    }
    const fromdata = new FormData();
    fromdata.append('archivo', archivo);
    fromdata.append('identidad', identidad);
    fromdata.append('nombre', nombre);
    fromdata.append('tipo', tipoDoc)
  //para crear el directorio
    const resp = await fetch('/directorio_cargar', {
        method:'POST',
        headers:{
            'Content-Type':'application/json'
        },
        body:JSON.stringify({identidad, tipoDoc})
    });
    const dataArchivo = await resp.json();
    if (!resp.ok) {
        alerta("[1]Error al subir archivo: "+ dataArchivo.mensaje);
    } else {
        //creacion subida del archivo
        const res_Archivo = await fetch(`/subir_archivo?identidad=${identidad}&nombre=${nombre}&tipo=${tipoDoc}`,{
            method:'POST',
            body:fromdata
        })
        const data_SUBIDA = await res_Archivo.json();
        if (!res_Archivo) {
            alerta("[2]Error al subir archivo: "+ data_SUBIDA.mensaje);
        } else {
            alerta(">"+ data_SUBIDA.mensaje);
        }
    }
    carga_archivos();
    document.getElementById('archivo').value = '';
    //btn_subir.disabled =false;
    mostrarCargando(false)
    //btn_load(false);
}


async function carga_archivos() {
    const identidad = document.getElementById('temp_identidad').value;
    const btn_subir = document.getElementById('btn_subir');
    mostrarCargando(true);
    const respuesta = await fetch(`/api/lista_archivos/${identidad}`);

    if (!respuesta.ok) {
        alerta("No tiene archivos subidos")
        mostrarCargando(false);
        //btn_subir.disabled =true;
    } 
    const datos = await respuesta.json();
    if (datos.length===0) {
        alerta("Se obtuvo respuesta, pero no hay datos que mostrar")
        mostrarCargando(false);
        //btn_subir.disabled =true;
    } 
    
    //const tbody = document.getElementById('tbl_archivos').querySelector('tbody');

    

const acordion = document.getElementById('acordion_archivos');



acordion.innerHTML = datos.length ? 

datos.map(D=>`
     <div class="accordion-item">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
            data-bs-target="#collapse${D.subcarpeta}" aria-expanded="false" aria-controls="collapse${D.subcarpeta}">
            <div class="pr-2"><span id="" class="badge bg-secondary pr-2">${D.DirArchivo.length}  </span></div>
            <b>${Obtener_tipoArchivo(D.subcarpeta)}</b>             
          </button>
        </h2>
        <div id="collapse${D.subcarpeta}" class="accordion-collapse collapse" data-bs-parent="#accordionExample">
          <div class="accordion-body">
                <div class="table-responsive" >
                    <table id="tbl_archivos" name="tbl_archivos"
                        class="table table-sm  table-hover table-active text-secondary-emphasis table-bordered border-primary">
                        <thead class="table-info">
                        <tr>
                            <th scope="col">Nombre del archivo</th>
                            <th scope="col">Peso</th>
                            <th scope="col">Fecha</th>
                            <th scope="col">Acción</th>
                        </tr>
                        </thead>
                        <tbody>
                         ${
                     D.DirArchivo.map(a=>`        
                <tr>
                    <td>${a.nombre}</td>
                    <td>${a.size}</td>
                    <td>${new Date(a.fecha).toLocaleDateString() }</td>
                    <td>
                    <div class="">
                        <a target="_blank" class="btn btn-primary btn-sm" href="/pdf/${identidad}/${D.subcarpeta}/${a.nombre}" role=""><i class="ri-eye-fill"></i></i></a>
                        <a class="btn btn-danger btn-sm" onclick="eliminarArchivo('${identidad}',${D.subcarpeta}, '${encodeURIComponent(a.nombre)}')"><i class="ri-delete-bin-line"></i></a>
                    </div>

                    </td>
                </tr>    
                `).join('')        
                         }
                        </tbody>
                    </table>
                </div>
          </div>
        </div>
      </div>

    `).join('')

: '<tr><td>No hay datos</td></tr>'



  document.getElementById('tbl_archivos').style.display='table';

  //btn_subir.disabled =false;
  mostrarCargando(false);
}


async function eliminarArchivo(identidad,tipo, nombreArchivo) {
    mostrarCargando(true); 
    const confirmar = confirm(`¿Está seguro que desea eliminar el archivo "${decodeURIComponent(nombreArchivo)}"?`);
    if (!confirmar) {
        mostrarCargando(false); 
        return;
    }    

    const respuesta = await fetch(`/api/eliminar_archivo/${identidad}/${tipo}/${nombreArchivo}`, {
        method: 'DELETE'
    });

    const resultado = await respuesta.json();

    if (respuesta.ok) {
        alert(resultado.mensaje);
        carga_archivos(); // recarga la tabla
    } else {
        alert("Error al eliminar: " + resultado.mensaje);
    }
    mostrarCargando(false); 
}