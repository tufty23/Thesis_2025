// Batch Transwell % Area Quantification Macro with Preview and Mask Saving
// this is for manual 0-200 thresholding with no fill holes for mid-high confluent images

// Select input folder
inputDir = getDirectory("Choose a folder with images");
outputFile = inputDir + "Transwell_PercentArea_Results.csv";

// Create mask output folder
maskDir = inputDir + "Processed_Masks/";
File.makeDirectory(maskDir);

// Write CSV header
File.saveString("Filename,PercentArea\n", outputFile);

// Get file list
list = getFileList(inputDir);

for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".jpg") || endsWith(list[i], ".png") || endsWith(list[i], ".tif")) {

        open(inputDir + list[i]);

        width = getWidth();
        height = getHeight();
        imageArea = width * height;

        // Preprocessing
        run("8-bit");
        run("Enhance Contrast...", "saturated=0.35 normalize");
        // setAutoThreshold("Otsu"); - not doing auto thresholding as differs between high and low conf images
        setThreshold(0,200);
        run("Convert to Mask");
        // run("Fill Holes"); - not doing this because removes true empty space in conf images
        run("Open");
        run("Erode");
        run("Dilate");

        // Preview
        //waitForUser("Preview: " + list[i] + 
        //    "\n\nClick OK to analyze this image.\n" + 
        //    "To skip it, click 'Cancel' on the next dialog.");

        //response = getBoolean("Continue with analysis?");
        //if (!response) {
        //    close();
        //    run("Clear Results");
        //    continue;
        //}

        // Save processed mask
        saveAs("PNG", maskDir + list[i]);

        // Analyze - 650 threshold set on size of pore (see ppt)
        run("Set Measurements...", "area redirect=None decimal=3");
        run("Analyze Particles...", "size=650-Infinity clear");

        totalArea = 0;
        n = nResults;
        for (j = 0; j < n; j++) {
            totalArea += getResult("Area", j);
        }

        percentArea = (totalArea / imageArea) * 100;
        File.append(list[i] + "," + d2s(percentArea, 3) + "\n", outputFile);

        close();
        run("Clear Results");
    }
}

showMessage("Batch Analysis Complete", "Results saved to:\n" + outputFile + 
            "\n\nProcessed masks saved to:\n" + maskDir);
