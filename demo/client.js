var wamp, topicName, topicPath, prefix;
var wsuri     = "ws://localhost:9292";

debugData = function(msg){
  $("#debug-data").append(msg + '</br>')
}

connect = function(){
  ab.connect(wsuri,
             // WAMP session was established
             function (session) {
               debugData("Session established.");
               wamp = session;
             },

             // WAMP session is gone
             function (code, reason) {
               switch (code) {
               case ab.CONNECTION_CLOSED:
          	 debugData("Connection was closed properly - done.");
                 break;
               case ab.CONNECTION_UNREACHABLE:
                 debugData("Connection could not be established.");
                 break;
    	       case ab.CONNECTION_UNSUPPORTED:
                 debugData("Browser does not support WebSocket.");
                 break;
               case ab.CONNECTION_LOST:
                 debugData("Connection lost - reconnecting ...");
                 break;
               }

               debugData("Session closed, code " + code + ", reason:" + reason)
             }
            );
};

subscribe = function(prefix){
  wamp.subscribe(prefix, onEvent);
}

unsubscribe = function(){
  wamp.unsubscribe(prefix, onEvent);
  topicPath = null;
}

registerPrefix = function(prefix, topic){
  prefix = prefix
  topicName = topic
  topicPath = wsuri + topicName;

  wamp.prefix(prefix, topicPath);
}

function onEvent(topicUri, event) {
  debugData(topicUri);
  debugData(event);
}

function sendSimpleMsg()
{
  msg = $("#simple-msg").val();
  $("#simple-msg").val("");

  wamp.publish(prefix, msg);
}
