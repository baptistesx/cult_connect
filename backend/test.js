$(document).ready(function () {

    var socket = io("localhost:8081");
    socket.emit('identification', "M_5e7a80125d33fe0d041ff8cb")
    // socket.emit('identification', "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNldXhiYXB0aXN0ZUBnbWFpbC5jb20iLCJpYXQiOjE2MDEzMjM2NTYsImV4cCI6MTYwMjYxOTY1Nn0.Y45L6gJITjQ6rGEcGhjexNiiBiFQokNTlF37alA8_9w" )



    year = 2000



    setInterval(function () {
        console.log("send new data: " + getRandomArbitrary(0, 50).toFixed(2))
        year += 1
        
        var dataToSend = {
            moduleId: '5e7a80125d33fe0d041ff8cb',
            sensorId: '5e81197a68819b45fce01000',
            data: {
                date: year + '-04-03T21:00:00.000+00:00',
                value: getRandomArbitrary(0, 50).toFixed(2)
            }
        }
        console.log(dataToSend)
        socket.emit('newDataFromModule', JSON.stringify(dataToSend))
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