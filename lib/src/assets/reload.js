const address = 'ws://localhost:{{ websocket_port }}';

function connect() {
  try {
    const socket = new WebSocket(address);
    socket.onmessage = function() {
      location.reload();
    };
    socket.onclose = function() {
      console.log('Connection closed.')
      connect();
    }
    socket.onerror = function() {
      console.log('Connection failed.')
      connect();
    }
  } catch (error) {
    console.log(`Error ${error}`);
    setInterval(() => {
      connect();
    }, 1000);
  }
}

connect();