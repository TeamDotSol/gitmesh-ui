var ipfsAPI = require('ipfs-api');

// pull in desired CSS/SASS files
require( './styles/main.scss' );

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );

// initialize ipfs
var ipfs = ipfsAPI({ host: 'localhost', port: '5001', protocol: 'http' });

app.ports.ipfsCat.subscribe(function (hash) {
    ipfs.files.cat(hash, function (err, file) {
        if (err) {
            console.error(err);
            return;
        }

        console.log(file.toString('utf-8'));
    })
});
