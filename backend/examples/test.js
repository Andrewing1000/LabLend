 console.log("prubey")


 fetch('http://127.0.0.1:8000/api/user/token/', {


 })
    .then(response1 => {
        // Process response1
        return response1.json(); // Parse JSON if needed
    })
    .then(data1 => {

        console.log(data)
        console.log(data1);
    })


