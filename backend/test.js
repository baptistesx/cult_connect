$(document).ready(function () {
    var socket = io("localhost:8081");
    socket.emit('identification', $("#moduleId").val())
    $("#test").submit(function (event) {
        // alert("Handler for .submit() called.");
        event.preventDefault();
        console.log($("#moduleId").val())
        var dataToSend = {
            'moduleId': '123',
            'sensorId': '111',
            'data': [{
                'date': '25/10/2020',
                'value': 30
            }]
        }
        socket.emit('newDataFromModule', dataToSend)//JSON.stringify(dataToSend))
    });


});