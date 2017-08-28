       ! ***************************************************
       ! ******* THIS CODE IS GENERATED. DO NOT EDIT *******
       ! ***************************************************
       module flow_control_logicals_mod
       use IO_tools_mod
       implicit none

       private
       public :: flow_control_logicals
       public :: init,delete,display,print,export,import

       interface init;   module procedure init_flow_control_logicals;           end interface
       interface delete; module procedure delete_flow_control_logicals;         end interface
       interface display;module procedure display_flow_control_logicals;        end interface
       interface display;module procedure display_wrapper_flow_control_logicals;end interface
       interface print;  module procedure print_flow_control_logicals;          end interface
       interface export; module procedure export_flow_control_logicals;         end interface
       interface import; module procedure import_flow_control_logicals;         end interface
       interface export; module procedure export_wrapper_flow_control_logicals; end interface
       interface import; module procedure import_wrapper_flow_control_logicals; end interface

       type flow_control_logicals
         logical :: post_process = .false.
         logical :: skip_solver_loop = .false.
         logical :: stop_before_solve = .false.
         logical :: stop_after_mesh_export = .false.
         logical :: poisson_test = .false.
         logical :: taylor_green_vortex_test = .false.
         logical :: temporal_convergence_test = .false.
         logical :: export_numerical_flow_rate = .false.
         logical :: export_shercliff_hunt_analytic_sol = .false.
         logical :: export_vorticity_streamfunction = .false.
         logical :: compute_export_e_k_budget = .false.
         logical :: compute_export_e_m_budget = .false.
         logical :: operator_interchangability_test = .false.
         logical :: export_final_tec = .false.
         logical :: export_final_restart = .false.
         logical :: restart_meshes = .false.
         logical :: export_heavy = .false.
         logical :: print_every_mhd_step = .false.
         logical :: compute_surface_power = .false.
       end type

       contains

       subroutine init_flow_control_logicals(this,that)
         implicit none
         type(flow_control_logicals),intent(inout) :: this
         type(flow_control_logicals),intent(in) :: that
         call delete(this)
         this%post_process = that%post_process
         this%skip_solver_loop = that%skip_solver_loop
         this%stop_before_solve = that%stop_before_solve
         this%stop_after_mesh_export = that%stop_after_mesh_export
         this%poisson_test = that%poisson_test
         this%taylor_green_vortex_test = that%taylor_green_vortex_test
         this%temporal_convergence_test = that%temporal_convergence_test
         this%export_numerical_flow_rate = that%export_numerical_flow_rate
         this%export_shercliff_hunt_analytic_sol = that%export_shercliff_hunt_analytic_sol
         this%export_vorticity_streamfunction = that%export_vorticity_streamfunction
         this%compute_export_e_k_budget = that%compute_export_e_k_budget
         this%compute_export_e_m_budget = that%compute_export_e_m_budget
         this%operator_interchangability_test = that%operator_interchangability_test
         this%export_final_tec = that%export_final_tec
         this%export_final_restart = that%export_final_restart
         this%restart_meshes = that%restart_meshes
         this%export_heavy = that%export_heavy
         this%print_every_mhd_step = that%print_every_mhd_step
         this%compute_surface_power = that%compute_surface_power
       end subroutine

       subroutine delete_flow_control_logicals(this)
         implicit none
         type(flow_control_logicals),intent(inout) :: this
         this%post_process = .false.
         this%skip_solver_loop = .false.
         this%stop_before_solve = .false.
         this%stop_after_mesh_export = .false.
         this%poisson_test = .false.
         this%taylor_green_vortex_test = .false.
         this%temporal_convergence_test = .false.
         this%export_numerical_flow_rate = .false.
         this%export_shercliff_hunt_analytic_sol = .false.
         this%export_vorticity_streamfunction = .false.
         this%compute_export_e_k_budget = .false.
         this%compute_export_e_m_budget = .false.
         this%operator_interchangability_test = .false.
         this%export_final_tec = .false.
         this%export_final_restart = .false.
         this%restart_meshes = .false.
         this%export_heavy = .false.
         this%print_every_mhd_step = .false.
         this%compute_surface_power = .false.
       end subroutine

       subroutine display_flow_control_logicals(this,un)
         implicit none
         type(flow_control_logicals),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) ' -------------------- flow_control_logicals'
         write(un,*) 'post_process                       = ',this%post_process
         write(un,*) 'skip_solver_loop                   = ',this%skip_solver_loop
         write(un,*) 'stop_before_solve                  = ',this%stop_before_solve
         write(un,*) 'stop_after_mesh_export             = ',this%stop_after_mesh_export
         write(un,*) 'poisson_test                       = ',this%poisson_test
         write(un,*) 'taylor_green_vortex_test           = ',this%taylor_green_vortex_test
         write(un,*) 'temporal_convergence_test          = ',this%temporal_convergence_test
         write(un,*) 'export_numerical_flow_rate         = ',this%export_numerical_flow_rate
         write(un,*) 'export_shercliff_hunt_analytic_sol = ',this%export_shercliff_hunt_analytic_sol
         write(un,*) 'export_vorticity_streamfunction    = ',this%export_vorticity_streamfunction
         write(un,*) 'compute_export_e_k_budget          = ',this%compute_export_e_k_budget
         write(un,*) 'compute_export_e_m_budget          = ',this%compute_export_e_m_budget
         write(un,*) 'operator_interchangability_test    = ',this%operator_interchangability_test
         write(un,*) 'export_final_tec                   = ',this%export_final_tec
         write(un,*) 'export_final_restart               = ',this%export_final_restart
         write(un,*) 'restart_meshes                     = ',this%restart_meshes
         write(un,*) 'export_heavy                       = ',this%export_heavy
         write(un,*) 'print_every_mhd_step               = ',this%print_every_mhd_step
         write(un,*) 'compute_surface_power              = ',this%compute_surface_power
       end subroutine

       subroutine print_flow_control_logicals(this)
         implicit none
         type(flow_control_logicals),intent(in) :: this
         call display(this,6)
       end subroutine

       subroutine export_flow_control_logicals(this,un)
         implicit none
         type(flow_control_logicals),intent(in) :: this
         integer,intent(in) :: un
         write(un,*) 'post_process                        = ';write(un,*) this%post_process
         write(un,*) 'skip_solver_loop                    = ';write(un,*) this%skip_solver_loop
         write(un,*) 'stop_before_solve                   = ';write(un,*) this%stop_before_solve
         write(un,*) 'stop_after_mesh_export              = ';write(un,*) this%stop_after_mesh_export
         write(un,*) 'poisson_test                        = ';write(un,*) this%poisson_test
         write(un,*) 'taylor_green_vortex_test            = ';write(un,*) this%taylor_green_vortex_test
         write(un,*) 'temporal_convergence_test           = ';write(un,*) this%temporal_convergence_test
         write(un,*) 'export_numerical_flow_rate          = ';write(un,*) this%export_numerical_flow_rate
         write(un,*) 'export_shercliff_hunt_analytic_sol  = ';write(un,*) this%export_shercliff_hunt_analytic_sol
         write(un,*) 'export_vorticity_streamfunction     = ';write(un,*) this%export_vorticity_streamfunction
         write(un,*) 'compute_export_e_k_budget           = ';write(un,*) this%compute_export_e_k_budget
         write(un,*) 'compute_export_e_m_budget           = ';write(un,*) this%compute_export_e_m_budget
         write(un,*) 'operator_interchangability_test     = ';write(un,*) this%operator_interchangability_test
         write(un,*) 'export_final_tec                    = ';write(un,*) this%export_final_tec
         write(un,*) 'export_final_restart                = ';write(un,*) this%export_final_restart
         write(un,*) 'restart_meshes                      = ';write(un,*) this%restart_meshes
         write(un,*) 'export_heavy                        = ';write(un,*) this%export_heavy
         write(un,*) 'print_every_mhd_step                = ';write(un,*) this%print_every_mhd_step
         write(un,*) 'compute_surface_power               = ';write(un,*) this%compute_surface_power
       end subroutine

       subroutine import_flow_control_logicals(this,un)
         implicit none
         type(flow_control_logicals),intent(inout) :: this
         integer,intent(in) :: un
         call delete(this)
         read(un,*); read(un,*) this%post_process
         read(un,*); read(un,*) this%skip_solver_loop
         read(un,*); read(un,*) this%stop_before_solve
         read(un,*); read(un,*) this%stop_after_mesh_export
         read(un,*); read(un,*) this%poisson_test
         read(un,*); read(un,*) this%taylor_green_vortex_test
         read(un,*); read(un,*) this%temporal_convergence_test
         read(un,*); read(un,*) this%export_numerical_flow_rate
         read(un,*); read(un,*) this%export_shercliff_hunt_analytic_sol
         read(un,*); read(un,*) this%export_vorticity_streamfunction
         read(un,*); read(un,*) this%compute_export_e_k_budget
         read(un,*); read(un,*) this%compute_export_e_m_budget
         read(un,*); read(un,*) this%operator_interchangability_test
         read(un,*); read(un,*) this%export_final_tec
         read(un,*); read(un,*) this%export_final_restart
         read(un,*); read(un,*) this%restart_meshes
         read(un,*); read(un,*) this%export_heavy
         read(un,*); read(un,*) this%print_every_mhd_step
         read(un,*); read(un,*) this%compute_surface_power
       end subroutine

       subroutine display_wrapper_flow_control_logicals(this,dir,name)
         implicit none
         type(flow_control_logicals),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call display(this,un)
         close(un)
       end subroutine

       subroutine export_wrapper_flow_control_logicals(this,dir,name)
         implicit none
         type(flow_control_logicals),intent(in) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call export(this,un)
         close(un)
       end subroutine

       subroutine import_wrapper_flow_control_logicals(this,dir,name)
         implicit none
         type(flow_control_logicals),intent(inout) :: this
         character(len=*),intent(in) :: dir,name
         integer :: un
         un = new_and_open(dir,name)
         call import(this,un)
         close(un)
       end subroutine

       end module