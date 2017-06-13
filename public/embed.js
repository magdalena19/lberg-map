window.onload = function() {
   //Params
   var scriptPram = document.getElementById('load_widget');
   var token = scriptPram.getAttribute('data-page');

   //iFrame
   var iframe = document.createElement('iframe');
   iframe.style.display = "none";
   iframe.src = "http://localhost:3000/" + token + '/embedded'
   document.body.appendChild(iframe);
};
