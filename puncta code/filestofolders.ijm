masterlist = "C:\\Users\\supersub\\Desktop\\Data\\filelist_MASTER.txt";
inputfolder = "C:\\Users\\supersub\\Desktop\\Data\\aggregate_all\\normalized\\";
groupfolders =  "C:\\Users\\supersub\\Desktop\\Data\\text files\\1cutoff 12disp\\";

allfiles = getFileList(inputfolder);
filestring=File.openAsString(masterlist); 
rows=split(filestring, "\n"); 

for (i=0; i<rows.length; i++) {
columns=split(rows[i],"\t"); 
dendrite_id=columns[0];
output=columns[2]; 
group=columns[5];

setBatchMode(true); 

for (n = 0; n < allfiles.length; n++) {
	if (1 == startsWith(allfiles[n], dendrite_id + " ")) {
	open(inputfolder + allfiles[n]);
	}
}

group_folder = groupfolders + group + File.separator + File.separator;
if (!File.exists(group_folder))
      File.makeDirectory(group_folder);

run("Images to Stack");
//saveAs("tif", output + dendrite_id + " 2dtseries_norm");
saveAs("tif", group_folder + dendrite_id + " 2dtseries_norm");
close();
}
