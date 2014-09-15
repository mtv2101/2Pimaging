input = "C:\\Users\\supersub\\Desktop\\Data\\2.8\\warped\\";
output = "C:\\Users\\supersub\\Desktop\\Data\\2.8\\rois\\11\\";

setBatchMode(true); 
list1 = getFileList(input);
for (i = 0; i < list1.length; i++)
        action1(input, output, list1[i]);
setBatchMode(false);
close();

list2 = getFileList(output);
for (i = 0; i < list2.length; i++)
        open(output + list2[i]);
setBatchMode(false);
run("Images to Stack");
run("StackReg", "transformation=[Rigid Body]");
//run("Subtract Background...", "rolling=15 sliding stack");
//run("Enhance Contrast...", "saturated=0.1 normalize process_all");
saveAs("tif", output + "2dtseries_");



function action1(input, output, filename) {
        open(input + filename);
        roiManager("Select", 0);
        run("Crop");
        run("Slice Keeper", "first=65 last=122 increment=1");
        //run("StackReg", "transformation=[Rigid Body]");
        run("Z Project...", "projection=[Max Intensity]");
        saveAs("tif", output + filename);
        close();
}
