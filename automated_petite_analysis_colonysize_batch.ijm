_RootFolder = getDirectory("Choose a Directory");
_csv = _RootFolder + "csv_files" + File.separator;

// Create directory if it doesn't exist
if (!File.exists(_csv)) {
    File.makeDirectory(_csv);
}

tifFiles = getTifFileList(_RootFolder);

// Enable Batch Mode
setBatchMode(true); 

for (i = 0; i < tifFiles.length; i++) {
    showProgress(i + 1, tifFiles.length); // Adds a progress bar in the ImageJ toolbar
    
    open(_RootFolder + tifFiles[i]);
    current = getImageID();
    
    // Processing steps
    run("Smooth");
    setThreshold(20116, 65535, "raw");
    run("Convert to Mask");
    makeOval(476, 220, 1640, 1665);
    run("Dilate");
    run("Watershed");
    
    // Particle Analysis
    run("Analyze Particles...", "size=0.0001-10000 circularity=0.70-1.00 display exclude clear add");
    
    // Save results using the filename without double extensions
    saveAs("Results", _csv + tifFiles[i] + ".csv");
    
    close(); 
}

// Disable Batch Mode and show all results
setBatchMode(false);
print("Batch processing complete.");

// --- Functions ---

function getTifFileList(folder) {
    fileList = getFileList(folder);
    tifFileList = newArray();
    for (j = 0; j < fileList.length; j++) {
        // Updated to handle both .tif and .Tif extensions
        if (endsWith(toLowerCase(fileList[j]), ".tif")) {
            tifFileList = Array.concat(tifFileList, fileList[j]);
        }
    }
    return tifFileList;
}