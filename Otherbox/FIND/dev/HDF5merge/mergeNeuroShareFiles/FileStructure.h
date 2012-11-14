#include <vector>
#include <string>
#include <map>
using namespace std;

#include <H5Cpp.h>
using namespace H5;

/**
 *	(C) Andreas Werber, 07.03.2008
 *  BCCN Uni-Freiburg
 */
namespace FileStructure
{
	/**
	 *	Structures for file handling.
	 */
	struct	Datastructure{ string name; };
	typedef vector<Datastructure> Datastructures;
	struct	Object{	string path; string name; Datastructures datastructures; };
	typedef vector<Object> Objects;
	struct  Record{	string name; Objects objects; };
	typedef vector<Record> Records;
	struct  FileStructure{ string filename; Records records; };

	/**
	 *	This is a recursive method for walking through dataspace. Since the dataspace
	 *	is organized in a tree structure, we perform a depth-first search calling 
	 *  recursively the getInfo method. Depth-first search stops as soon as a leaf, 
	 *  i.e. a dataset, is reached. The path to this dataset, its name and its unique 
	 *  ID is stored in an object class. The whole procedure runs as long as there are 
	 *  branches to search.
	 */
	void explorePath(Group* group, Record& record, string path = "")
	{
		// Get number of objects stored in the actual group.
		const hsize_t num_objects = group->getNumObjs();

		// Iterate through all objects.
		for(hsize_t i = 0; i < num_objects; i++)
		{
			// Get type of current object.
			const H5G_obj_t object_type = group->getObjTypeByIdx(i);

			// If the current object is a group, we know that there
			// must be at least one dataset left in this branch to
			// be consulted. Hence we recursively call the method
			// again, passing the current group node as a root node
			// for the getInfo method.
			if(object_type == H5G_obj_t::H5G_GROUP)
			{
				// Get name of current object.
				const string group_name = group->getObjnameByIdx(i);
				cout << "  found group \"" << group_name << "\"" << endl;
				
				// Open current group node.
				Group* group_new = new Group(group->openGroup(group_name));

				// Get path to current node and append the object's name
				// to be the next starting path.
				const string path_new = path + "/" + group_name;

				// Recursively call getInfo method.
				explorePath(group_new,record,path_new);

				// Free aquired dataspace.
				group_new->close();
				delete group_new;
			}

			// If the current object is a dataset, we know that we've 
			// reached a leaf node, i.e. a dataset in which the current 
			// explored path ends. We extract the necessary information and
			// store the data in a new object.
			if(object_type == H5G_obj_t::H5G_DATASET)
			{
				// Create new object structure.
				Object object;

				// Check path to current object and extract the 
				// name of this object.
				size_t n = path.find_last_of("/");
				if(n != path.npos)
				{
					object.path = path.substr(0,n);
					object.name = path.substr(n+1,path.size());
				}
				else
				{
					object.path = "";
					object.name = "";
				}
				
				// Get name of current object's datastructure.
				const string datastructure_name = group->getObjnameByIdx(i);
				cout << "  found datastructure \"" << datastructure_name << "\"" << endl;
				
				// Create new datastructure.
				Datastructure datastructure;
				datastructure.name = datastructure_name;

				// Add datastruture to current object.
				object.datastructures.push_back(datastructure);
				record.objects.push_back(object);
			}
		}
	}

	/**
	 *	This method searches a Neuroshare HDF file and extracts the basic 
	 *  datastructure to an object called FileStructure. This objects
	 *  represents the internal data tree structure of this file.
	 */
	FileStructure exploreFile(string filename)
	{
		cout << "FILE EXPLORER" << endl;
		cout << "=============" << endl << endl;

		cout << "exploring file \"" << filename << "\" by depth-first tree search:" << endl;

		// Create new filestructure.
		FileStructure filestructure;
		filestructure.filename = filename;

		H5File* file = 0;
		try
		{
			file = new H5File(filename,H5F_ACC_RDONLY);
		}
		catch(FileIException &e)
		{
			cout << "error opening file" << endl;
			return filestructure;
		}

		// Since one or more datastructures are linked to one object structure,
		// all datastructures within one object contain the same path. Therefore
		// we use a mappping from an object name to a list of datastructure 
		// objects (because of the same path, by pushing back new datastructures
		// to an object structure we can avoid redundancy. In other words it 
		// represents a helping structure for data sorting.
		map< string, map<string,Datastructures> > mapper;
		map< string, map<string,Datastructures> >::const_iterator mapper_citer;
		map< string, Datastructures >::const_iterator	datastructures_citer;

		const hsize_t num_records = file->getNumObjs();
		for(hsize_t i = 0; i < num_records; i++)
		{
			// Get the current record name.
			const string record_name = file->getObjnameByIdx(i);

			// And open its group.
			Group* record_group = new Group(file->openGroup(record_name));

			// Create new record structure.
			Record record;
			record.name = record_name;

			// Recursively explore the dataset tree.
			explorePath(record_group,record);

			cout << endl << "search sucessfully finished" << endl;
			cout << "restructuring data ... ";

			// Clear all previous entries in the mapping structure.
			mapper.clear();

			// Parse all object entries in the record structure 
			// and store them in the mapping structure. The purpose
			// of this is to eliminate redundancy in the paths 
			// structures, since depth-first search may generate 
			// ambiguities in the path names.
			const size_t num_objects = record.objects.size();
			for(size_t j = 0; j < num_objects; j++)
			{
				const Object object = record.objects.at(j);
						
				for(size_t k = 0; k < object.datastructures.size(); k++)
				{
					const Datastructure datastructure = object.datastructures.at(k);
					mapper[object.path][object.name].push_back(datastructure);
				}
			}

			// After having stored all data in the mapping structure,
			// we can savely clear the entries in the object structure.
			record.objects.clear();

			// Finally we write back the (now ordered) data from the mapping 
			// structure to the object structure.
			for(mapper_citer = mapper.begin(); mapper_citer != mapper.end(); ++mapper_citer)
			{
				const string object_path = mapper_citer->first;
				for(datastructures_citer = mapper_citer->second.begin(); datastructures_citer != mapper_citer->second.end(); ++datastructures_citer)
				{
					const string			object_name				= datastructures_citer->first;
					const Datastructures	object_datastructures	= datastructures_citer->second;
					
					Object object; 
						object.path		= object_path;
						object.name		= object_name;
						object.datastructures = object_datastructures;

					record.objects.push_back(object);
				}
			}
			
			// Clear all previous entries in the mapping structure.
			filestructure.records.push_back(record);
	
			// Clear memory.
			record_group->close();
			delete record_group;
		}

		// Since the data within the mapping structure is written to the 
		// filestructure, we can savely clear the data.
		mapper.clear();

		cout << "done" << endl;

		// Free memory.
		file->close();
		delete file;

		cout << "filestructure completely explored, closing file" << endl << endl << endl;
		return filestructure;
	}


	/**
	 *	This is a simple method for displaying the internal datastruture of a file
	 *  represented by its Filestructure object.
	 */
	void printFileStructure(FileStructure filestructure)
	{
		const size_t num_records = filestructure.records.size();

		cout << "FILESTRUCTURE INFORMATION" << endl;
		cout << "=========================" << endl << endl;

		cout << "filestructure contains " << num_records << " record(s)." << endl;

		for(size_t i = 0; i < num_records; i++)
		{
			const Record record = filestructure.records.at(i);
			const size_t num_objects = record.objects.size();
			
			cout << endl;
			cout << "  record(" << i << ") name=\"" << record.name << "\" contains " << num_objects << " object(s):" << endl;
			cout << endl;
			
			for(size_t j = 0; j < num_objects; j++)
			{
				const Object object = record.objects.at(j);
				const size_t num_datastructures = object.datastructures.size();

				cout << "   object(" << j << ") path=\"" << object.path << "\", ID=\"" << object.name << "\" contains " << num_datastructures << " dataset(s):" << endl;
				for(size_t k = 0; k < num_datastructures; k++)
				{
					const Datastructure datastructure = object.datastructures.at(k);
					cout << "    dataset(" << k << ") name=\"" << datastructure.name << "\"" << endl;
				}
				cout << endl;
			}
		}

		cout << endl << endl;
	}


	/**
	 *	Simple method for comparing two strings for being equal or not.
	 */
	__inline bool is_equal(string A, string B)
	{
		return ( strcmp(A.c_str(),B.c_str()) == 0 );
	}


	/**
	 *	This method compares two FileStructures and deletes any ambiguities in the latter
	 *	datastructure. This is done be tracing all paths in the datastructures and by
	 *	comparing the unique IDs of the datasets. If both the names of the records and the
	 *  objects IDs are equal, we can securely delete the reference in the second filestructure,
	 *  since the object is represented by the first datastructure.
	 */
	FileStructure deleteSiblings(FileStructure fs_A, FileStructure fs_B)
	{
		cout << "ELIMINATE REDUNDANCY" << endl;
		cout << "====================" << endl << endl;

		cout << "comparing filestructures for redundancy ... " << endl;

		Records::iterator			rec_iter_A, rec_iter_B;
		Objects::iterator			obj_iter_A, obj_iter_B;
		Datastructures::iterator	dat_iter_A, dat_iter_B;

		FileStructure __fs_B = fs_B;

		for(rec_iter_A = fs_A.records.begin(); rec_iter_A != fs_A.records.end(); ++rec_iter_A)
		{
			for(rec_iter_B = __fs_B.records.begin(); rec_iter_B != __fs_B.records.end(); ++rec_iter_B)
			{
				if( is_equal(rec_iter_A->name,rec_iter_B->name) )
				{
					cout << "  found record name match = \"" << rec_iter_A->name << "\"" << endl;

					for(obj_iter_A = rec_iter_A->objects.begin(); obj_iter_A != rec_iter_A->objects.end(); ++obj_iter_A)
					{
						for(obj_iter_B = rec_iter_B->objects.begin(); obj_iter_B != rec_iter_B->objects.end(); ++obj_iter_B)
						{
							if( is_equal(obj_iter_A->name,obj_iter_B->name) )
							{
								cout << "   found object ID match = \"" << obj_iter_A->name << "\"" << endl;

								for(dat_iter_A = obj_iter_A->datastructures.begin(); dat_iter_A != obj_iter_A->datastructures.end(); ++dat_iter_A)
								{
									for(dat_iter_B = obj_iter_B->datastructures.begin(); dat_iter_B != obj_iter_B->datastructures.end(); ++dat_iter_B)
									{
										if( is_equal(dat_iter_A->name,dat_iter_B->name) )
										{
											cout << "    found datastructure name match = \"" << dat_iter_A->name << "\" erasing ... " << endl;
											obj_iter_B->datastructures.erase(dat_iter_B);
											break;
										}
									}
								}

								// If the second datastructure looses all child objects,
								// we delete the root node of this dataset.
								if(obj_iter_B->datastructures.empty())
								{
									rec_iter_B->objects.erase(obj_iter_B);
									break;
								}

							}
						}
					}
				}
			}
		}

		cout << "done" << endl << endl << endl;

		return __fs_B;
	}

	/**
	 *	In this method, a string object is parsed and split at 
	 *  the split character "/", returning a vector of single 
	 *  string objects.
	 */
	__inline vector<string> splitString(string str, char c = '/')
	{
		vector<string> paths;
		if(str.empty()) return paths;

		// Find first index of the split character.
		size_t curr_pos = str.find(c);
		const size_t n = str.size();

		// While not reaching the end of the string cut out all substrings
		// between two split characters and add them to the path list.
		// Exit loop if end of string has been reached.
		while(curr_pos < str.size())
		{
			size_t next_pos = str.find(c,curr_pos+1);
	
			if(next_pos == str.npos) next_pos = str.size();
			const string substring = str.substr(curr_pos+1,next_pos-curr_pos-1);
			if(!substring.empty()) paths.push_back(substring);
			
			curr_pos = next_pos;
		}

		return paths;
	}

	/**
	 * This method adds a new group object to a datastructure. We can compare the
	 * data structure to a tree structure. Parameters are the file to which the new 
	 * group object is to be written, the parent node name/path and the name of the 
	 * new (child) object. If the groupname already exists, we do nothing.
	 */
	void addGroup(H5File* file, string new_group_name, string curr_group_name = "/")
	{
		Group* curr_group = 0;
		Exception::dontPrint();

		try
		{
			cout << "opening current group \"" << curr_group_name << "\" ... ";
			curr_group = new Group(file->openGroup(curr_group_name));
			cout << "successfull" << endl;

			cout << "adding new group \"" << new_group_name << "\" to group \"" << curr_group_name << "\" ... ";
			curr_group->createGroup(new_group_name);
			cout << "successfull" << endl;
		}
		catch(GroupIException &e)
		{
			cout << "group already exists" << endl;
		}
		catch(FileIException &e)
		{
			cout << "error writing to file" << endl;
		}

		curr_group->close();
		delete curr_group;
	}

	
	/**
	 *	Here, we write down the datastructure of a certain file to 
	 *  a new file. The switch "append" is used to either append the
	 *	data to an existing file or to create a new file.
	 */
	void writeFileStructure(string filename_out, FileStructure fs, bool append)
	{
		cout << "WRITING FILESTRUCTURE" << endl;
		cout << "=====================" << endl << endl;

		cout << "writing filestructure to file (mode=";
		if(append) cout << "append"; else cout << "truncate";
		cout << ")" << endl;

		try
		{
			// Open source file.
			H5File* file_in  = new H5File(fs.filename,H5F_ACC_RDONLY);

			// Open/create destination file to be written to (according to switch parameter).
			H5File* file_out = 0;
			if(append){	file_out = new H5File(filename_out,H5F_ACC_RDWR); } else { file_out = new H5File(filename_out,H5F_ACC_TRUNC); }

			// Get number of stored record structures.
			const size_t num_records = fs.records.size();

			// Iterate through all records and write according data from the source 
			// file to the destination file.
			for(size_t i = 0; i < num_records; i++)
			{
				// Open i-th record item.
				const Record record = fs.records.at(i);
				cout << "writing record \"" << record.name << "\" ... " << endl;
			
				// Add new record node to datatree.
				addGroup(file_out,record.name);

				// Get number of stored objects in the record object.
				const size_t num_objects = record.objects.size();

				// Iterate through all objects and write the according data objects
				// to the file.
				for(size_t j = 0; j < num_objects; j++)
				{
					// Open j-th object item.
					const Object object = record.objects.at(j);

					// Build the path to the datastructures to be written to disk.
					// This is done iteratively, because we can just add ONE child
					// node to a parent node at once. After that the current child
					// node becomes the next parent node. We do this until a complete
					// path has been build.
					const vector<string> object_paths = splitString(object.path);
					string curr_group_name = record.name;
					for(size_t k = 0; k < object_paths.size(); k++)
					{
						const string next_group_name = object_paths.at(k);
						addGroup(file_out,next_group_name,curr_group_name);
						curr_group_name = curr_group_name + "/" + next_group_name;
					}

					// The last path to add is the object's name represeting its ID.
					addGroup(file_out,object.name,curr_group_name);
				
					// Get number of stored datastructures.
					const size_t num_datastructures = object.datastructures.size();

					const string full_object_path = curr_group_name + "/" + object.name;

					// Iterate through all stored datastructures and write them
					// to the destination file.
					for(size_t k = 0; k < num_datastructures; k++)
					{
						try
						{
							const string dataset_name = object.datastructures.at(k).name;

							// Open both source and destination dataset.
							DataSet* dataset_input  = new DataSet( file_in->openDataSet(full_object_path + "/" + dataset_name) );
							DataSet* dataset_output = new DataSet( file_out->createDataSet(full_object_path + "/" + dataset_name, dataset_input->getDataType(), dataset_input->getSpace()) ); 

							// Write data from source file to buffer and then the 
							// buffer data to the destination file.
							void* buffer = malloc( dataset_input->getStorageSize() );
							dataset_input->read( buffer, dataset_input->getDataType() );
							dataset_output->write( buffer, dataset_output->getDataType() );
							free(buffer);

							// Like the previous written data, we have to do the same
							// procedure for the attributes.
							const hsize_t num_attributes = dataset_input->getNumAttrs();
							for(hsize_t l = 0; l < num_attributes; l++)
							{
								Attribute* dataset_input_attr  = new Attribute(dataset_input->openAttribute(l));
								Attribute* dataset_output_attr = new Attribute(dataset_output->createAttribute(dataset_input_attr->getName(),dataset_input_attr->getDataType(),dataset_input_attr->getSpace()));

								void* buffer = malloc(dataset_input_attr->getStorageSize());
								dataset_input_attr->read(dataset_input_attr->getDataType(),buffer);
								dataset_output_attr->write(dataset_output_attr->getDataType(),buffer);
								free(buffer);
						
								dataset_input_attr->close();  delete dataset_input_attr;
								dataset_output_attr->close(); delete dataset_output_attr;
							}

							// Free allocated memory.
							dataset_input->close();
							delete dataset_input;

							dataset_output->close();
							delete dataset_output;
						}
						catch(FileIException &e)
						{
							cout << "error writing to disk" << endl;
							return;
						}
					}
				}
			}

			// Close files and free memory.
			file_out->close();
			delete file_out;
		
			file_in->close();
			delete file_in;
		}
		catch(FileIException &e)
		{
			cout << "error writing to disk" << endl;
		}

		cout << endl << endl;
	}

};








/*
	bool hasPath(H5File* file, string path)
	{
		try
		{
			Exception::dontPrint();
			file->openGroup(path);
		}
		catch(FileIException e)
		{
			return false;
		}
		
		return true;
	}

	bool hasPath(Group* group, string path)
	{
		try
		{
			Exception::dontPrint();
			group->openGroup(path);
		}
		catch(FileIException e)
		{
			return false;
		}
		
		return true;
	}
	*/