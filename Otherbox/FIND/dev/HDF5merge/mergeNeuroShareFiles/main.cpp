#include <iostream>
#include <string>
using namespace std;

#include "FileStructure.h"

int main(int argc, char** argv)
{
	/*
	string path = "C:\\Dokumente und Einstellungen\\user\\Eigene Dateien\\Visual Studio 2005\\Projects\\mergeNeuroShareFiles\\";
	string filename_A = "TestA.h5";
	string filename_B = "TestC.h5";
	string filename_out = "M.h5";
	*/

	if(argc < 4)
	{
		cout << "USAGE: mergeNeuroShareFiles <inputfile1> <inputfile2> <mergefile>" << endl;
		return -1;
	}

	string filename_A   = argv[1];
	string filename_B   = argv[2];
	string filename_out = argv[3];

	FileStructure::FileStructure fs_A = FileStructure::exploreFile(filename_A);
	FileStructure::printFileStructure(fs_A);

	FileStructure::FileStructure fs_B = FileStructure::exploreFile(filename_B);
	FileStructure::printFileStructure(fs_B);

	FileStructure::FileStructure fs_BB = FileStructure::deleteSiblings(fs_A,fs_B);
	FileStructure::printFileStructure(fs_BB);

	FileStructure::writeFileStructure(filename_out,fs_A, false);
	FileStructure::writeFileStructure(filename_out,fs_BB, true);

	//int Z; cin >> Z;
	return 0;
}
