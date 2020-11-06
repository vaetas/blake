var socket = new WebSocket('ws://localhost:4041');
socket.onmessage = function(event) {
  location.reload();
};