masterlist = "C:\\Users\\supersub\\Desktop\\Data\\filelist_MASTER_test.txt";
inputfolder = "C:\\Users\\supersub\\Desktop\\Data\\aggregate_all\\normalized\\";

allfiles = getFileList(inputfolder);
filestring=File.openAsString(masterlist); 
rows=split(filestring, "\n"); 
//dendrite_id=newArray(rows.length);
//output=newArray(rows.length);

for (i=0; i<rows.length; i++) {
columns=split(rows[i],"\t"); 
dendrite_id=columns[0];
output=columns[2]; 

setBatchMode(true); 

for (n = 0; n < allfiles.length; n++) {
	if (1 == startsWith(allfiles[n], dendrite_id + " ")) {
	open(allfiles[n]);
	}
}
run("Images to Stack");
saveAs("tif", output + " 2dtseries_norm");
close();
}
