// timers
var hasNewMessagesTimer;
var hasNewChatsTimer;
var scrollDownMessagesTimer;

$(function(){
    $(".heading-compose").click(function() {
      $(".side-two").css({
        "left": "0"
      });
    });

    $(".newMessage-back").click(function() {
      $(".side-two").css({
        "left": "-100%"
      });
    });
});

function scrollDownMessages() {
  clearTimeout(scrollDownMessagesTimer);
}

function openMessages(chaturl) {
  clearTimeout(hasNewMessagesTimer);

  $('#chat_messages').load(chaturl, function(data) {

  });
}