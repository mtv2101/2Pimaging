masterlist = "C:\\Users\\supersub\\Desktop\\Data\\filelist_MASTER_test.txt";
aggregate_folder = "C:\\Users\\supersub\\Desktop\\Data\\aggregate_all\\temp\\";

filestring=File.openAsString(masterlist); 
rows=split(filestring, "\n"); 
output=newArray(rows.length);

for(i=0; i<rows.length; i++) { 
columns=split(rows[i],"\t"); 
output[i]=columns[2]; 

outputdir = output[i] + "batch output" + File.separator + File.separator;
listtemp= getFileList(outputdir);
for (k = 0; k < listtemp.length; k++) {
	if (1 == endsWith(listtemp[k], "2dtseries.tif")) {
        	open(outputdir + listtemp[k]);
	run("Enhance Contrast...", "saturated=0.01 normalize process_all");
        	Stack.getDimensions(width, height, channels, slices, frames) 
        		for (n = 0; n < slices; n++) {
        		Stack.setSlice(n+1)
        		run("Copy"); 
          		newImage("Untitled", "8-bit Black", width, height, 1); 
          		run("Paste");
		name = replace(listtemp[k], '.tif', '');
          		saveAs("tif", outputdir + name  + "_slice" + n);
          		saveAs("tif", aggregate_folder + name + "_slice" + n);
		close();
        		}
	close();
	}
}
}
