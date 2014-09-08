masterlist = "C:\\Users\\supersub\\Desktop\\Data\\filelist_MASTER_test.txt";
aggregate_folder = "C:\\Users\\supersub\\Desktop\\Data\\aggregate_all\\";

filestring=File.openAsString(masterlist); 
rows=split(filestring, "\n"); 
dendrite_id=newArray(rows.length);
input=newArray(rows.length); 
output=newArray(rows.length);
cut_top=newArray(rows.length);
cut_bottom=newArray(rows.length);

for(i=0; i<rows.length; i++){ 
columns=split(rows[i],"\t"); 
dendrite_id[i]=columns[0];
input[i]=columns[1];
output[i]=columns[2]; 
cut_top[i]=columns[3]; 
cut_bottom[i]=columns[4]; 

setBatchMode(true); 

listin = getFileList(input[i]);
listout = getFileList(output[i]);

tempdir = output[i]+ "batch output" + File.separator + File.separator;
File.makeDirectory(tempdir);

zcut_string = "first=" + cut_top[i] + " last=" + cut_bottom[i] + " increment=1";
for (n = 0; n < listin.length; n++)
        action1(input[i], output[i], listin[n], listout, zcut_string, dendrite_id[i], tempdir);
setBatchMode(false);
close();

listtemp= getFileList(tempdir);
for (k = 0; k < listtemp.length; k++)
        open(tempdir + listtemp[k]);
setBatchMode(false);
run("Images to Stack");
//run("StackReg", "transformation=[Rigid Body]");
run("Subtract Background...", "rolling=15 sliding stack");
saveAs("tif", tempdir + dendrite_id[i] + " 2dtseries");
close();

//run("Particle Tracker 2D/3D", "radius=3 cutoff=0 per/abs=1 link=1 displacement=8");
}


function action1(input, output, filename, listout, string, dendrite_id, tempdir) {
        open(input + filename);
	for (m = 0; m < listout .length; m++)
	if (1 == endsWith(listout[m], ".roi"))
	roiManager("Open", output + listout[m]);
        	roiManager("Select", 0);
        	run("Crop");
       	run("Slice Keeper", string);
      	run("Z Project...", "projection=[Max Intensity]");
       	name = replace(filename, '.tif', '');
        	saveAs("tif", tempdir + dendrite_id + "_" + name);
	roiManager("reset")
        	close();
}
