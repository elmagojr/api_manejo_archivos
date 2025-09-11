const Tipos_Documentos = [
    {codigo:1, descripcion: 'Identificaciones'},
    {codigo:2, descripcion: 'RTN'},
    {codigo:3, descripcion: 'Contratos'},
    {codigo:4, descripcion: 'Escrituras'},
    {codigo:5, descripcion: 'Croquis'},
    {codigo:6, descripcion: 'Otros documentos'}      
]

 function Obtener_tipoArchivo(tipo) {   
   var tipoStr =''
   Tipos_Documentos.map(x=>{
     if (x.codigo ==tipo) {
       tipoStr = x.descripcion
     }
   })
   return tipoStr;    
 };


 const select_tipos =document.getElementById('Stipo');
   //select_tipos.innerHTML = '<option selected>Seleccione un tipo de documento</option>';
 select_tipos.innerHTML = '<option value="0" selected>Seleccione un tipo de documento</option>'+ 
 (Tipos_Documentos.length ?  Tipos_Documentos.map(a=>`    
    <option value="${a.codigo}">${a.descripcion}</option>   
    `).join('')
   : '<option selected>Seleccione un tipo de documento</option>');