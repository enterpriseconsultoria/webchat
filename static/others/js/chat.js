trigger_notification = function (titulo, corpo, icone)
{
    //check if browser supports notification API
    if("Notification" in window)
    {
        if(Notification.permission !== "granted")
        {
        	Notification.requestPermission().then(function(result){
        		console.log(Notification.permission);
        		if(result === "granted")
        		{
					trigger_notification(titulo, corpo, icone);
				}
			});
        }
        else
        {
            var notification = new Notification(titulo, {"body":corpo, "icon":icone});	
        }
    }
}   
imgs = ["jpg", "png","bmp", "gif"];

DOMenabled = false;

notification = new Audio("/static/sounds/1.mp3");
notification_ready = false;
notification.addEventListener("canplay", function(e){notification_ready = true});

booting = true;

newMessage = function(){
	console.log("notImplemented");
	return;
}

readURL = function(ele, file) {
    if (ele && file) {
        var reader = new FileReader();

        reader.onload = function (e) {
            $(ele).css('background',"url('"+e.target.result+"')");
        };
        reader.readAsDataURL(file);
    }
}
var uploader;

createUploader = function(csrf){
	if(uploader === undefined){
		uploader = new Dropzone("#file-janela-modal", {
		paramName: "uploadfile", 
		maxFilesize: 20, // MB
		accept: function(file, done) {
			done();
		},
		addRemoveLinks: true,
		autoProcessQueue: false,
		dictRemoveFile: "Remover",
		dictUploadCanceled:"Envio Cancelado",
		dictResponseError: "Falha ao enviar arquivo. O servidor retornou {{statusCode}}.",
		dictDefaultMessage: "Arraste os arquivos ou clique aqui.",
		dictCancelUploadConfirmation:"Tem certeza de que deseja cancelar o envio deste arquivo?",
		url: $("#chat").attr("data-url")+"/message/add/"});
	
		var prevw = new FileReader();
		d = new Date().toISOString().split("T")[1].substr(0,8);
    	prevw.onload = function(e) {
    		f ='<div class="mensagem sent">\n<div class="orelha"></div>\n<div class="conteudo"><a href="'+e.target.result+'" target="_blank" > <img width="200px" src="'+e.target.result+'"> </img> </a><p></p><div class="status">'+d+'</div><br/></div>';
      		$('#chat .msgs').append(f);
		}

		$('#file-fechar-janela').on('click', function(){
			if(uploader.getUploadingFiles() > 0 || uploader.getQueuedFiles() > 0 || uploader.files.length > 0)
				if(!confirm("Deseja cancelar o envio dos arquivos?"))
					return;
			uploader.removeAllFiles();
			$("#filemodal").addClass("escondido");
			$("#enviarArquivos").removeAttr("disabled");
		});
		uploader.on("sending", function(a,b,c){
			c.append($(csrf).attr("name"), $(csrf).attr("value"));
			c.append("mtype", "document");
		});
		uploader.on("error", function(file){
			setTimeout(function(){uploader.removeFile(file)}, 5000);
		});
		uploader.on("success", function(file){
			uploader.removeFile(file);
			prevw.readAsDataURL(file);
		});
		uploader.on("removedfile", function(file){
			if(uploader.files.length == 0){
				$("#enviarArquivos").removeAttr("disabled");
				$("#filemodal").addClass("escondido");
			}

		});
		$('#chat').on('dragover dragenter', function(e) {
	        e.preventDefault();
	        if($("#mensagem-input").hasClass("disabled")){
	        	return false;
	        }
			$("#filemodal").removeClass("escondido");
		});


		uploader.on("queuecomplete ", function(){
			$("#enviarArquivos").removeAttr("disabled");
		});
		uploader.on("reset ", function(file){
			$("#enviarArquivos").removeAttr("disabled");
		});

		$("#enviarArquivos").on('click', function(){
			if(uploader.getUploadingFiles() > 0 || uploader.getQueuedFiles() > 0 || uploader.files.length > 0){
				$(this).attr("disabled", "disabled");
				uploader.processQueue();
			}
		});
	}else{
		uploader.on("sending", function(a,b,c){
			c.append($(csrf).attr("name"), $(csrf).attr("value"));
			c.append("mtype", "document");
		});
		uploader.options.url = $("#chat").attr("data-url")+"/message/add/";
		uploader.enable();		
	}
	console.log(uploader.options.url);
}

distroyUploader = function(){
	try{
	uploader.disable();
	}catch(a){

	}
}

wpformat = function(strg){
	return strg;
	var filter_strikethrough = /(?:[\b >])([~])(.+?)([~])/g;
	var filter_italic = /(?:[\b >])([_])(.+?)([_])/g;
	var filter_bold = /(?:[\b >])([*])(.+?)([*])/g;
	var match;

	var control = false;
	for(var i=0; i < strg.length; i++){
		if(parseInt(strg.codePointAt(i)) >= 9000 ){
			if(!control){
				strg = strg.substr(0,i)+'<span class="emoji">'+strg.substr(i);
				i+=21;
				control = true;
			}
		}
		else{
			if(control){
				strg = strg.substr(0,i)+'</span>'+strg.substr(i);
				control = false;
				i+=7;
			}
		}
	}

	while(match = filter_bold.exec(strg)){
		var start = filter_bold.lastIndex - match[0].length;
		var end = filter_bold.lastIndex-1;
		console.log(match);

		strg = strg.substr(0,start+1)+"<b>"+match[2] +"</b>"+strg.substr(end);
	}

	match = undefined;
	while(match = filter_italic.exec(strg)){
		var start = filter_italic.lastIndex - match[0] .length;
		var end = filter_italic.lastIndex-1;    
		strg = strg.substr(0,start+1)+"<i>"+match[2] +"</i>"+strg.substr(end);
	}

	match = undefined;
	while(match = filter_strikethrough.exec(strg)){
		var start = filter_strikethrough.lastIndex - match[0] .length;
		var end = filter_strikethrough.lastIndex-1;    
	    strg = strg.substr(0,start+1)+"<del>"+match[2] +"</del>"+strg.substr(end);
	}
	return strg;
}



$(document).ready(function(){
	doEmoji = function(){
		return;
		$('.msgs').off('DOMNodeInserted');
		$('.conversa .dados .ultima-mensagem').each(function(){
			if($(this).find(".emoji").length == 0)
				$(this).html(wpformat($(this).html()));
		});
		$(".mensagem").each(function(){
			if($(this).find(".conteudo").find(".emoji").length == 0){
				var text = $(this).find(".conteudo").html();
				text = wpformat(text);
				$(this).find(".conteudo").html(text);
			}
		});
		$('.msgs').on('DOMNodeInserted', function(){
			doEmoji();
		});
		$('.msgs').on('DOMNodeInserted', function(){
			doEmoji();
		});
	}


	$("body").on('click', function(e) {
		DOMenabled = true;
	});

	$(document).on('dragenter dragover', function(e) {
			e.preventDefault();
	});
	$(document).on('dragdrop drop', function(e) {
		if (e.target.id != "file-janela-modal"){
			alert("Inicie o atendimento");
			e.preventDefault();
			return false;
		}
		return true;
	});
	
   if (Recorder.isRecordingSupported()) {
      $("#mic").removeClass("invalido");
    }

	/*
	* Atualiza o layout
	*/
	h = $("#conteudo").height()
	h -= $("#mensagem-input").height();
	h -= $("#conteudo").find(".top-bar").height();
	$("#chat").css("height", h+"px");

	/*
	* Menu principal
	*/
	$("#mainMenu").find(".menu").find(".menu-item").on("click", function(){
		var attr = $(this).attr("data-sair");
		if(typeof attr !== typeof undefined && attr !== false){
			window.location.replace($(this).attr("data-href"));
			return true;
		}
		else{
	    	$("#janela-modal").attr("src", $(this).attr("data-href"));
	    	$("#modal-window").removeClass("escondido");
		}

	});

	/*
	* Esconde/Mostra menu principal
	*/
	$(".top-bar").find("#menu-toogler").on("click", function(){
		 $("#mainMenu").removeClass("escondido");
		 $("#mainMenuBack").removeClass("escondido");
	});
	$("#mainMenuBack").on("click", function(){
		 $("#mainMenu").addClass("escondido");
		 $("#mainMenuBack").addClass("escondido");
	});

	/*
	* Mostra o menu lateral
	*/
	$("#conteudo").find("#back").on("click", function(){
		 $("#conteudo").addClass("escondido");
		 $("#sidebar").removeClass("escondido");
	});

	/*
	*
	* Desativar chat input
	*
	*/


	$("#mensagem-input").find('*').each(function(){
		$(this).on("click keydown keyup keypress tap", function(e){
			if($("#mensagem-input").hasClass("disabled")){
				e.preventDefault();
				return false;
			}
		})
	});

	$("#mensagem-input").find('*').each(function(){
		$(this).on("click keydown keyup keypress", function(e){
			if($("#mensagem-input").hasClass("disabled")){
				e.preventDefault();
				return false;
			}
		})
	});




	/*
	* Mostra o chat
	*/
	$(".conversas").on('click', '.conversa', function() {
    	$("#conteudo").removeClass("escondido");
    	$("#sidebar").addClass("escondido");

    	$('#chat').load($(this).attr("data-url"), function(){
    		doEmoji();
    	});
    	$('#chat').attr("data-url", $(this).attr("data-url"));
    	if(!$(this).hasClass("selecionada")){
	    	$(".selecionada").removeClass("selecionada");
	    	$(this).addClass("selecionada");
	    	$(this).find(".unreaded").html(0);
	    	$conversa = $(this);
	    	$chat = $("#conteudo").find(".top-bar");
	    	$chat.find(".foto").html($conversa.find(".foto").html());
	    	$chat.find(".dados").find(".nome").html($conversa.find(".dados").find(".nome").html());
			$("#mensagem-input-field").val("");
		}
	});
	$('body').on('DOMSubtreeModified', '.conversas', function (e) {
		$(".conversas .conversa").each(function(i,el){
			if($(el).attr("data-url") === $("#chat").attr("data-url"))
				$(el).addClass("selecionada");
		});
		$(".conversas .selecionada").find(".unreaded").each(function(a,b){
			if($(b).html() !== "0")
				$(b).html("0");
		});
		$(".unreaded").each(function(i,el){
			if($(el).html() === "0")
				$(el).css("opacity", 0);
			else
				$(el).css("opacity", 1);
		});
	});




	$(".atendimento").on("click", function(){
		$("#chat").find(".opts").toggle(250);
	});

	/*
	* Fecha o modal
	*/
	$("#fechar-janela").on('click', function() {
		$("#modal-window").addClass("escondido");
		$("#janela-modal").contents().find('body').html("Carregando...");
	});


	/*
	* Amplia a caixa de texto, quando necessário ou envia mensagem
	*/
	$("#mensagem-input-field").on("keydown", function(e){
		if($("#mensagem-input").hasClass("disabled")){
			e.preventDefault();
			return false;
		}

        if(e.shiftKey){
        	return true;
        }

	 	if (e.keyCode == 13 ) {
        	var message = $(this).val();
 			if($.trim(message) != '') {
 				newMessage(message);
			}
 			$("#mensagem-input-field").val("");
			$(this).attr("rows", 1);
			h = $("#conteudo").height()
			h -= $("#mensagem-input").height();
			h -= $("#conteudo").find(".top-bar").height();
			$("#chat").css("height", h+"px");
        	return false;
    	}
    	return true;
	});
	$("#mensagem-input-field").on("input", function(){
		row = $(this).val().split("\n").length;
		if(row > 5)
			row = 5;
		if(row == 0)
			row = 1;
		$(this).attr("rows", row);

		h = $("#conteudo").height()
		h -= $("#mensagem-input").height();
		h -= $("#conteudo").find(".top-bar").height();
		$("#chat").css("height", h+"px");
	});


	/*
	*Atualiza o layout ao redimencionar
	*/
	$(window).on("resize", function(){
		h = $("#conteudo").height()
		h -= $("#mensagem-input").height();
		h -= $("#conteudo").find(".top-bar").height();
		$("#chat").css("height", h+"px");
	});

	/*
	* Grava e envia
	*/
	$("#mic").on("click", function(){
		if($(this).hasClass("invalido"))
			return false;
		if(recording){
			stopRecording();
			$("#mic-cancelar").hide();
		}
		else{
			startRecording();
		}
	});
	/*
	* Cancela Gravação
	*/
	$("#mic-cancelar").on("click", function(){
		cancelRecording();
		$("#mic-cancelar").hide();
	});

	/*
	* Rola o chat pra baixo
	*/
	$("#chat").on("DOMSubtreeModified", function(){
	   setTimeout(function(){$("#chat").scrollTop($("#chat").get(0).scrollHeight)}, 100);
	});

	/*
	* Audio player
	*/

	$('body').on('DOMNodeInserted', '#chat > .msgs > .mensagem', function (e) {
		e.stopPropagation();
		$it = $(this).find(".conteudo").find(".audio");
		if(!$it || $it.find("audio").length !=0)
			return false;
		url=$it.attr("data-src");
		audio = new Audio(url);
		$(audio).attr("controls", true);
		$it.append(audio);
		audios.push(audio);
	});
	$("audio").on('play', function() {
		for (var i = 0; i >=  audios.length; i++) {
			if (audio !== this)
				audios[i].pause();
		}
	});


	$('#file').on('click', function(){
		$("#filemodal").removeClass("escondido");
	});




	sendAudio = function(audio){
		var t = MD5(new Date().getTime());

		$("#audio-uploader").append('<div id="'+t+'"></div>');

		var dz = new Dropzone("#"+t, {
			paramName: "audio", 
			maxFilesize: 20, // MB
			accept: function(file, done) {
				done();
			},
			url: "/file/post" });
		dz.on("success", function(file){
			$(audio).parent().addClass("sucesso");
		});

		dz.on("error", function(file){
			$(audio).parent().addClass("falha");
		});
	};
	//trigger_notification("teste", "teste", "https://postcron.com/pt/blog/wp-content/uploads/2016/05/foto-de-perfil-para-trabalho.jpg");
});

