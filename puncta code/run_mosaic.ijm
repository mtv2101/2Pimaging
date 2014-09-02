masterlist = "C:\\Users\\supersub\\Desktop\\Data\\filelist_MASTER.txt";
groupfolders =  "C:\\Users\\supersub\\Desktop\\Data\\text files\\2cutoff 8disp\\";

filestring=File.openAsString(masterlist); 
rows=split(filestring, "\n"); 

for(i=0; i<rows.length; i++) { 
columns=split(rows[i],"\t"); 
dendrite_id=columns[0];
group=columns[5];

setBatchMode(true); 

group_folder = groupfolders + group + File.separator + File.separator;
if (!File.exists(group_folder))
      File.makeDirectory(group_folder);

listout = getFileList(group_folder);
for (k = 0; k < listout.length; k++) {
	if (1 == matches(listout[k], dendrite_id + " 2dtseries_norm.tif")) {
	open(group_folder + listout[k]);
	run("Particle Tracker 2D/3D", "radius=3 cutoff=0 per/abs=2 link=1 displacement=8");
	}
}

} 
