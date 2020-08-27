$(document).ready(function () {
    var socket = io("localhost:8081");
    socket.emit('identification', "MODULE_5e7a80125d33fe0d041ff8cb" )
    year = 2000
    setInterval(function () {
        console.log("send new data: " + getRandomArbitrary(0, 50).toFixed(2))
        year += 1
        var dataToSend = {
            moduleId: '5e7a80125d33fe0d041ff8cb',
            moduleIndex: 0,
            sensorId: '5e81197a68819b45fce01000',
            sensorIndex: 0,
            data: [{
                date: year + '-04-03T21:00:00.000+00:00',
                value: getRandomArbitrary(0, 50).toFixed(2)
            }]
        }
        console.log(dataToSend)
        socket.emit('newDataFromModule', dataToSend)
    }, 2000);

    $("#test").submit(function (event) {
        event.preventDefault();
        var dataToSend = {
            moduleId: '5e7a80125d33fe0d041ff8cb',
            moduleIndex: 0,
            sensorId: '5e81197a68819b45fce01000',
            sensorIndex: 0,
            data: [{
                date: '2020-04-03T21:00:00.000+00:00',
                value: getRandomArbitrary(0, 50)
            }]
        }
        console.log(dataToSend)
        socket.emit('newDataFromModule', dataToSend)
    });


});

function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}