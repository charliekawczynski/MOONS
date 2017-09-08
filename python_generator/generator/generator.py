import os
import sys
from collections import OrderedDict
import collections
import GOOFPY_directory as GD
import fortran_module as FM
import module_merging as MM
import funcs as func
import inspect

class generator:
	def __init__(self):
		self.module = OrderedDict()
		self.module_list = []
		self.combined_modules = []
		self.abstract_interfaces = OrderedDict()
		self.used_modules = []
		self.base_files = []
		self.base_modules = []
		self.overwritten_module_list = []
		return

	def set_directories(self,d):
		self.d = d
		func.delete_entire_tree_safe(self.d.target_dir)
		func.make_path(self.d.target_dir)
		func.make_path(self.d.bin_dir)
		return self

	def set_default_real(self,default_real): self.default_real = default_real
	def set_combined_modules(self,combined_modules): self.combined_modules = self.combined_modules+[combined_modules]
	def add_base_files(self,base_files): self.base_files = self.base_files+base_files
	def add_base_modules(self,base_modules): self.base_modules = self.base_modules+base_modules

	def print(self):
		self.d.print_local()

	def add_module(self,module_name):
		self.module_list = self.module_list+[module_name]
		if module_name in self.module:
			self.overwritten_module_list = self.overwritten_module_list+[module_name]
		self.module[module_name] = FM.fortran_module()
		self.module[module_name].set_default_real(self.default_real)
		self.module[module_name].set_name(module_name)
		return

	def set_abstract_interfaces(self):
		for key in self.module:
			temp = self.module[key].abstract_interfaces
			if temp:
				self.abstract_interfaces[key]=temp
		return

	def generate_code(self):
		N_tot = 0
		PS = self.d.PS
		print(' ----------------------------- module_list ----------------------------- ')
		print(','.join(self.module_list))
		print(' ----------------------------------------------------------------------- ')
		# module_list_temp = [self.module[key].folder_name+PS+self.module[key].name for key in self.module]

		combined_modules_flat = [item for sublist in self.combined_modules for item in sublist]
		module_list_temp = []
		for key in self.module:
			if not any([key in x for x in combined_modules_flat]):
				module_list_temp.append(self.module[key].folder_name+PS+self.module[key].name)

		print('----------------------------- overwritten_module_list')
		print(self.overwritten_module_list)
		print('----------------------------- abstract_interfaces')
		self.set_abstract_interfaces()
		L = [self.abstract_interfaces[k] for k in self.abstract_interfaces]
		L = [item for sublist in L for item in sublist]
		print('\n'.join(L))
		print('-----------------------------')

		duplicates = [item for item, count in collections.Counter(self.module_list).items() if count > 1]
		# Get full path to duplicates:
		duplicates_full = [[x for x in module_list_temp if k in x] for k in duplicates]
		duplicates_full = [item for sublist in duplicates_full for item in sublist]
		# if not is_empty(duplicates):
		if len(duplicates_full)>0:
			raise ValueError('Error: Duplicate classes: '+','.join(duplicates_full))

		for key in self.module:
			func.make_path(self.d.target_dir + self.module[key].folder_name + PS)

		self.base_spaces = self.module[key].base_spaces

		for key in self.module:
			if not any([key in x for x in combined_modules_flat]):
				L = self.module[key].contruct_fortran_module(self.module_list,self.abstract_interfaces,self.base_modules)
				path = self.d.target_dir+self.module[key].folder_name+PS+key+self.d.fext
				func.write_string_to_file(path,'\n'.join(L))
				N_tot = N_tot+len(L)

		for CM in self.combined_modules:
			m = OrderedDict()
			for key in CM:
				m[key] = self.module[key].contruct_fortran_module(self.module_list,self.abstract_interfaces,self.base_modules)
			combined_name = FM.longest_sub_string_match_list(CM)
			if combined_name.endswith('_'): combined_name = combined_name[:-1]
			if combined_name.startswith('_'): combined_name = combined_name[1:]
			L = MM.combine_modules(m,CM,self.base_spaces)
			path = self.d.target_dir+self.module[key].folder_name+PS+combined_name+self.d.fext
			module_list_temp.append(self.module[key].folder_name+PS+combined_name)
			func.write_string_to_file(path,'\n'.join(L))
			N_tot = N_tot+len(L)

		# func.make_dot_bat(self.d.target_root,self.d.GOOFPY_dir,self.d.target_dir,module_list_temp,self.d.base_dir,self.base_files,self.d.PS)
		func.make_makefile(self.d.makefile_file,self.d.target_root,self.d.GOOFPY_dir,self.d.target_dir,module_list_temp,self.d.base_dir,self.base_files,'$(PS)')
		# func.make_dummy_main(self.d.target_dir+'main_dummy.f90',self.module_list,self.base_spaces)
		print('Number of lines generated (Total): ' + str(N_tot))
