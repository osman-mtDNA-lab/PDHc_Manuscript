/*
 * This macro uses the 3D version of "analyze particles" called "3D Objects Counter" to quantify objects in a 
 * z-stack. It goes into a folder with single cell crop images called "Channel_2", measures the image with the plugin
 * and saves the table with the image name as csv
 * 
 * 
 */

_RootFolder = getDirectory("Choose a Directory");
list = getTifFileList(_RootFolder+ File.separator + "Channel_3" );
File.makeDirectory(_RootFolder + "Tables");
//run("Set Scale...", "distance=1 known=0.11 unit=µm");

setBatchMode(true);
for (file = 0; file<list.length; file++) {
	filename=list[file];
	open(_RootFolder + File.separator + "Channel_3/" + list[file]);
	run("Set Scale...", "distance=1 known=0.11 unit=µm");
	pic = getTitle();
	print(pic);
	pic = replace(pic, ".tif", "");
	image= getTitle();
	
	Stack.setSlice(21);
	resetMinAndMax();
	run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
	selectImage("3D_Median");
	run("3D Fast Filters","filter=TopHat radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
	selectImage("3D_TopHat");
	run("3D Maxima Finder", "minimmum=0 radiusxy=1.50 radiusz=1.50 noise=1200");
	run("3D Spot Segmentation", "seeds_threshold=15 local_background=2500 local_diff=0 radius_0=2 radius_1=4 radius_2=6 weigth=0.50 radius_max=10 sd_value=1.17 local_threshold=[Gaussian fit] seg_spot=Maximum watershed volume_min=1 volume_max=1000000 seeds=peaks_3D_TopHat spots="+pic+" radius_for_seeds=2 output=Both");
	Ext.Manager3D_AddImage();
	selectWindow(image);
	Ext.Manager3D_Measure();
	Ext.Manager3D_SaveResult("M",_RootFolder+ "Tables"+ File.separator +pic + ".csv");
	Ext.Manager3D_Quantif();
	Ext.Manager3D_SaveResult("Q",_RootFolder+ "Tables"+ File.separator +pic + ".csv");
	Ext.Manager3D_Delete();
	Ext.Manager3D_CloseResult("Q");
	Ext.Manager3D_CloseResult("M");
	Ext.Manager3D_Delete();
	Ext.Manager3D_Close();
	run("Close All");
	}
	

setBatchMode(false);	
	
function getTifFileList(directory){
	item = 0;
	fileList = getFileList(directory);
	tifFileList = newArray();
	while (item < fileList.length)  {
		if (endsWith(fileList[item],".tif") ) {		
			tifFileList = Array.concat(tifFileList, fileList[item]);
			}
	item += 1;
	}
	return tifFileList;
}