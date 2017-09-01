# **************** INCLUDE PATHS ********************
VPATH +=\
	$(TARGET_DIR)\
	$(SRC_DIR)$(PS)block\
	$(SRC_DIR)$(PS)BCs\
	$(SRC_DIR)$(PS)BCs$(PS)apply\
	$(SRC_DIR)$(PS)BCs$(PS)base\
	$(SRC_DIR)$(PS)BCs$(PS)direct\
	$(SRC_DIR)$(PS)BCs$(PS)implicit\
	$(SRC_DIR)$(PS)clock\
	$(SRC_DIR)$(PS)convergence_rate\
	$(SRC_DIR)$(PS)coordinates\
	$(SRC_DIR)$(PS)dir_tree\
	$(SRC_DIR)$(PS)domain\
	$(SRC_DIR)$(PS)mesh_params\
	$(SRC_DIR)$(PS)fields\
	$(SRC_DIR)$(PS)fields$(PS)default\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_matmult_3D\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_global\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_export_import\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_embed_extract\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_restrict_prolongate\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_interp_extrap\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_symmetry\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_CFL_number\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_Fourier_number\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_Robin_BC_coeff\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)BF\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)SF\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)VF\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)TF\
	$(SRC_DIR)$(PS)globals\
	$(SRC_DIR)$(PS)grid\
	$(SRC_DIR)$(PS)IO\
	$(SRC_DIR)$(PS)lib\
	$(SRC_DIR)$(PS)material_props\
	$(SRC_DIR)$(PS)math\
	$(SRC_DIR)$(PS)mesh\
	$(SRC_DIR)$(PS)norms\
	$(SRC_DIR)$(PS)ops\
	$(SRC_DIR)$(PS)procedure_array\
	$(SRC_DIR)$(PS)probe\
	$(SRC_DIR)$(PS)sim_params\
	$(SRC_DIR)$(PS)var_set\
	$(SRC_DIR)$(PS)solvers\
	$(SRC_DIR)$(PS)solvers$(PS)energy\
	$(SRC_DIR)$(PS)solvers$(PS)density\
	$(SRC_DIR)$(PS)solvers$(PS)FFT\
	$(SRC_DIR)$(PS)solvers$(PS)GS\
	$(SRC_DIR)$(PS)solvers$(PS)induction\
	$(SRC_DIR)$(PS)solvers$(PS)Jacobi\
	$(SRC_DIR)$(PS)solvers$(PS)MG\
	$(SRC_DIR)$(PS)solvers$(PS)momentum\
	$(SRC_DIR)$(PS)solvers$(PS)PCG\
	$(SRC_DIR)$(PS)solvers$(PS)PSE\
	$(SRC_DIR)$(PS)solvers$(PS)SOR\
	$(SRC_DIR)$(PS)solvers$(PS)preconditioners\
	$(SRC_DIR)$(PS)sparse\
	$(SRC_DIR)$(PS)stencils\
	$(SRC_DIR)$(PS)table\
	$(SRC_DIR)$(PS)time_statistics\
	$(SRC_DIR)$(PS)user\
	$(SRC_DIR)$(PS)matrix_visualization\
	$(SRC_DIR)$(PS)version

# **************** SOURCE FILES *********************

SRCS_F +=\
	$(SRC_DIR)$(PS)globals$(PS)constants.f90\
	$(SRC_DIR)$(PS)material_props$(PS)material_props.f90\
	$(SRC_DIR)$(PS)BCs$(PS)face_edge_corner_indexing.f90\
	$(SRC_DIR)$(PS)math$(PS)simple_int_tensor.f90\
	$(SRC_DIR)$(PS)fields$(PS)data_location.f90\
	$(SRC_DIR)$(PS)math$(PS)is_nan.f90\
	$(SRC_DIR)$(PS)math$(PS)even_odd.f90\
	$(SRC_DIR)$(PS)IO$(PS)fmt.f90\
	$(SRC_DIR)$(PS)IO$(PS)datatype_conversion.f90\
	$(SRC_DIR)$(PS)IO$(PS)exp_Tecplot_Zone.f90\
	$(SRC_DIR)$(PS)IO$(PS)exp_Tecplot_Header.f90\
	$(SRC_DIR)$(PS)grid$(PS)array_extend.f90\
	$(SRC_DIR)$(PS)grid$(PS)sparse_extend.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)export_logicals.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)sim_config_params.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)dimensionless_params.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)dimensionless_params_extend.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)geometry_props.f90\
	$(SRC_DIR)$(PS)mesh_params$(PS)mesh_quality_params_extend.f90\
	$(SRC_DIR)$(PS)mesh_params$(PS)segment_extend.f90\
	$(SRC_DIR)$(PS)mesh_params$(PS)mesh_params_extend.f90\
	$(SRC_DIR)$(PS)dir_tree$(PS)path_extend.f90\
	$(SRC_DIR)$(PS)dir_tree$(PS)dir_group_extend.f90\
	$(SRC_DIR)$(PS)dir_tree$(PS)dir_tree_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)RK_params_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)solver_settings_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)matrix_free_params_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)time_marching_params_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)iter_solver_params_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)export_line_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)export_lines_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)export_plane_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)export_planes_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)export_field_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)var_extend.f90\
	$(SRC_DIR)$(PS)var_set$(PS)var_set_extend.f90\
	$(SRC_DIR)$(PS)table$(PS)table.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)derivative_stencils.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)interpolation_stencils.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)coordinates_extend.f90\
	$(SRC_DIR)$(PS)domain$(PS)overlap.f90\
	$(SRC_DIR)$(PS)grid$(PS)grid_extend.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)coordinate_stretch_parameters.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)coordinate_distribution_funcs.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)coordinate_distribution_funcs_iterate.f90\
	$(SRC_DIR)$(PS)coordinates$(PS)coordinate_stretch_param_match.f90\
	$(SRC_DIR)$(PS)grid$(PS)grid_init.f90\
	$(SRC_DIR)$(PS)grid$(PS)grid_continue.f90\
	$(SRC_DIR)$(PS)grid$(PS)grid_connect.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_base.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_assign.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_add.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_subtract.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_multiply.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_divide.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_add_product.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_product_add.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_square.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_square_root.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_arithmatic_3D$(PS)GF_cross_product.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_assign_plane.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_assign_plane_ave.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_add_plane.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_assign_ghost.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_assign_wall.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_multiply_plane.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_multiply_wall.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_assign_ghost_periodic.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_interp_extrap$(PS)GF_extrap.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_interp_extrap$(PS)GF_interp.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_restrict_prolongate$(PS)GF_restrict.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_restrict_prolongate$(PS)GF_prolongate.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_aux.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_export_import$(PS)GF_export.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_export_import$(PS)GF_import.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_embed_extract$(PS)GF_embed_extract.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_distributions.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_CFL_number$(PS)GF_CFL_number.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_Fourier_number$(PS)GF_Fourier_number.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_Robin_BC_coeff$(PS)GF_Robin_BC_coeff.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_diagonals.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_plane_sum.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_plane_mean.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_2D$(PS)GF_mean_along_dir.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_symmetry$(PS)GF_symmetry_error.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_symmetry$(PS)GF_mirror_about_plane.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_norms_weights.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_norms.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_matmult_3D$(PS)GF_laplacian.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF_matmult_3D$(PS)GF_curl_curl.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)GF$(PS)GF.f90\
	$(SRC_DIR)$(PS)sparse$(PS)sparse_field.f90\
	$(SRC_DIR)$(PS)sparse$(PS)sparse_mult.f90\
	$(SRC_DIR)$(PS)sparse$(PS)stencil_1D.f90\
	$(SRC_DIR)$(PS)sparse$(PS)stencil_3D.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)bctype.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)BC_logicals.f90\
	$(SRC_DIR)$(PS)domain$(PS)sub_domain.f90\
	$(SRC_DIR)$(PS)domain$(PS)physical_sub_domain.f90\
	$(SRC_DIR)$(PS)domain$(PS)face_SD.f90\
	$(SRC_DIR)$(PS)domain$(PS)edge_SD.f90\
	$(SRC_DIR)$(PS)block$(PS)block_curl_curl_stencil.f90\
	$(SRC_DIR)$(PS)block$(PS)block_Laplacian_stencil.f90\
	$(SRC_DIR)$(PS)block$(PS)block.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_props.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh.f90\
	$(SRC_DIR)$(PS)domain$(PS)physical_domain.f90\
	$(SRC_DIR)$(PS)BCs$(PS)direct$(PS)apply_BCs_faces_raw.f90\
	$(SRC_DIR)$(PS)BCs$(PS)direct$(PS)apply_BCs_edges_raw.f90\
	$(SRC_DIR)$(PS)BCs$(PS)direct$(PS)apply_BCs_faces_bridge.f90\
	$(SRC_DIR)$(PS)BCs$(PS)implicit$(PS)apply_BCs_faces_raw_implicit.f90\
	$(SRC_DIR)$(PS)BCs$(PS)implicit$(PS)apply_BCs_faces_bridge_implicit.f90\
	$(SRC_DIR)$(PS)procedure_array$(PS)single_procedure.f90\
	$(SRC_DIR)$(PS)procedure_array$(PS)procedure_array.f90\
	$(SRC_DIR)$(PS)procedure_array$(PS)single_procedure_plane_op.f90\
	$(SRC_DIR)$(PS)procedure_array$(PS)procedure_array_plane_op.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)single_boundary.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)boundary.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)boundary_conditions.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)BF$(PS)BF.f90\
	$(SRC_DIR)$(PS)block$(PS)mesh_block.f90\
	$(SRC_DIR)$(PS)time_statistics$(PS)stats_period.f90\
	$(SRC_DIR)$(PS)time_statistics$(PS)time_statistics_params.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)equation_term.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)energy_terms.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)momentum_terms.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)induction_terms.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)export_frequency_params.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)export_frequency.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)mirror_props.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)flow_control_logicals.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)sim_params.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)sim_params_aux.f90\
	$(SRC_DIR)$(PS)sim_params$(PS)sim_params_extend.f90\
	$(SRC_DIR)$(PS)user$(PS)restart_file.f90\
	$(SRC_DIR)$(PS)user$(PS)kill_switch.f90\
	$(SRC_DIR)$(PS)user$(PS)export_now.f90\
	$(SRC_DIR)$(PS)user$(PS)export_safe.f90\
	$(SRC_DIR)$(PS)user$(PS)refine_mesh.f90\
	$(SRC_DIR)$(PS)domain$(PS)mesh_domain.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_PD_geometries.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_BC_geometries.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_complex_BC_geometries.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_benchmark_geometries.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_generate.f90\
	$(SRC_DIR)$(PS)mesh$(PS)generate_mesh_generic.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)SF$(PS)SF.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)VF$(PS)VF.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)TF$(PS)TF.f90\
	$(SRC_DIR)$(PS)fields$(PS)default$(PS)index_mapping.f90\
	$(SRC_DIR)$(PS)mesh$(PS)mesh_stencils.f90\
	$(SRC_DIR)$(PS)IO$(PS)base_export.f90\
	$(SRC_DIR)$(PS)IO$(PS)base_import.f90\
	$(SRC_DIR)$(PS)IO$(PS)construct_suffix.f90\
	$(SRC_DIR)$(PS)IO$(PS)IO_export.f90\
	$(SRC_DIR)$(PS)IO$(PS)IO_import.f90\
	$(SRC_DIR)$(PS)IO$(PS)import_raw.f90\
	$(SRC_DIR)$(PS)version$(PS)version.f90\
	$(SRC_DIR)$(PS)clock$(PS)unit_conversion.f90\
	$(SRC_DIR)$(PS)clock$(PS)clock.f90\
	$(SRC_DIR)$(PS)clock$(PS)stop_clock.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_norms.f90\
	$(SRC_DIR)$(PS)norms$(PS)norms.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_fft.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_dct.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_idct.f90\
	$(SRC_DIR)$(PS)stencils$(PS)stencils.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_del.f90\
	$(SRC_DIR)$(PS)BCs$(PS)base$(PS)check_BCs.f90\
	$(SRC_DIR)$(PS)BCs$(PS)apply$(PS)apply_BCs.f90\
	$(SRC_DIR)$(PS)BCs$(PS)apply$(PS)apply_BCs_implicit.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_embedExtract.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_interp.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_mirror_field.f90\
	$(SRC_DIR)$(PS)IO$(PS)export_raw_processed.f90\
	$(SRC_DIR)$(PS)IO$(PS)export_raw_processed_symmetry.f90\
	$(SRC_DIR)$(PS)IO$(PS)export_processed_FPL.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_aux.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_discrete.f90\
	$(SRC_DIR)$(PS)ops$(PS)ops_advect.f90\
	$(SRC_DIR)$(PS)probe$(PS)probe_extend.f90\
	$(SRC_DIR)$(PS)BCs$(PS)BC_funcs.f90\
	$(SRC_DIR)$(PS)time_statistics$(PS)time_statistics.f90\
	$(SRC_DIR)$(PS)solvers$(PS)matrix_free_operators.f90\
	$(SRC_DIR)$(PS)solvers$(PS)matrix_based_operators.f90\
	$(SRC_DIR)$(PS)solvers$(PS)preconditioners$(PS)diagonals.f90\
	$(SRC_DIR)$(PS)solvers$(PS)preconditioners$(PS)preconditioners.f90\
	$(SRC_DIR)$(PS)solvers$(PS)AB2.f90\
	$(SRC_DIR)$(PS)solvers$(PS)update_intermediate_field_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)compute_energy.f90\
	$(SRC_DIR)$(PS)sparse$(PS)matrix.f90\
	$(SRC_DIR)$(PS)solvers$(PS)FFT$(PS)FFT_poisson.f90\
	$(SRC_DIR)$(PS)solvers$(PS)Jacobi$(PS)Jacobi_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)Jacobi$(PS)Jacobi.f90\
	$(SRC_DIR)$(PS)solvers$(PS)GS$(PS)GS_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)GS$(PS)GS_poisson.f90\
	$(SRC_DIR)$(PS)solvers$(PS)SOR$(PS)SOR.f90\
	$(SRC_DIR)$(PS)solvers$(PS)PSE$(PS)PSE_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)PSE$(PS)PSE.f90\
	$(SRC_DIR)$(PS)solvers$(PS)PCG$(PS)PCG_aux.f90\
	$(SRC_DIR)$(PS)solvers$(PS)PCG$(PS)PCG_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)PCG$(PS)PCG.f90\
	$(SRC_DIR)$(PS)solvers$(PS)clean_divergence.f90\
	$(SRC_DIR)$(PS)solvers$(PS)time_marching_methods.f90\
	$(SRC_DIR)$(PS)solvers$(PS)time_marching_methods_SF.f90\
	$(SRC_DIR)$(PS)solvers$(PS)density$(PS)init_rho_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)density$(PS)init_rho_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)density$(PS)density_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)density$(PS)density.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)energy_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)init_T_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)init_gravity_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)init_T_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)init_K.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)energy_aux.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)energy_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)energy.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)momentum_stability.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)vorticity_streamfunction.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)profile_funcs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)export_analytic.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)init_U_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)init_P_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)init_U_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)init_Ustar_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)init_P_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)E_K_budget_terms.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)E_K_budget.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)momentum_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)momentum_aux.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)momentum.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)induction_aux.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)Mike_Ulrickson_data.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)assign_B0_vs_t.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)curl_curl_B.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)E_M_budget_terms.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)E_M_budget.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_phi_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_B_BCs.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_phi_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_B_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_Bstar_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_B0_field.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_B_interior.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_J_interior.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)init_Sigma.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)induction_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)induction_solver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)induction.f90\
	$(SRC_DIR)$(PS)solvers$(PS)energy$(PS)add_all_energy_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)momentum$(PS)add_all_momentum_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)induction$(PS)add_all_induction_sources.f90\
	$(SRC_DIR)$(PS)solvers$(PS)MHDSolver.f90\
	$(SRC_DIR)$(PS)solvers$(PS)Poisson_test.f90\
	$(SRC_DIR)$(PS)solvers$(PS)Taylor_Green_Vortex_test.f90\
	$(SRC_DIR)$(PS)solvers$(PS)temporal_convergence_test.f90\
	$(SRC_DIR)$(PS)solvers$(PS)operator_interchangability_test.f90\
	$(SRC_DIR)$(PS)user$(PS)export_mesh_aux.f90\
	$(SRC_DIR)$(PS)matrix_visualization$(PS)matrix_visualization.f90\
	$(SRC_DIR)$(PS)user$(PS)MOONS.f90

SRCS_F += $(TARGET_DIR)$(PS)parametricStudy.f90
