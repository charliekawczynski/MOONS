       module MHDSolver_mod
       use current_precision_mod
       use sim_params_mod
       use VF_mod
       use IO_tools_mod
       use IO_auxiliary_mod
       use string_mod
       use path_mod
       use dir_tree_mod
       use stop_clock_mod
       use print_export_mod

       use time_marching_params_mod
       use energy_mod
       use momentum_mod
       use induction_mod
       use energy_aux_mod
       use induction_aux_mod
       implicit none
       
       private
       public :: MHDSolver

       contains

       subroutine MHDSolver(nrg,mom,ind,DT,SP,coupled)
         implicit none
         type(energy),intent(inout) :: nrg
         type(momentum),intent(inout) :: mom
         type(induction),intent(inout) :: ind
         type(dir_tree),intent(in) :: DT
         type(sim_params),intent(in) :: SP
         type(time_marching_params),intent(inout) :: coupled
         type(stop_clock) :: sc
         type(VF) :: F ! Forces added to momentum equation
         integer :: n_step
         logical :: continueLoop
         type(print_export) :: PE

         call init(F,mom%U)
         call assign(F,0.0_cp)
         continueLoop = .true.

         call writeSwitchToFile(.true.,str(DT%params),'killSwitch')
         call writeSwitchToFile(.false.,str(DT%params),'exportNow')
         call writeSwitchToFile(.false.,str(DT%params),'exportNowU')
         call writeSwitchToFile(.false.,str(DT%params),'exportNowB')
         call writeSwitchToFile(.false.,str(DT%params),'exportNowT')

         write(*,*) 'Working directory = ',str(DT%tar)
         ! ***************************************************************
         ! ********** SOLVE MHD EQUATIONS ********************************
         ! ***************************************************************
         call init(sc,coupled%n_step_stop-coupled%n_step)
         do n_step = coupled%n_step,coupled%n_step_stop
           call init(PE,coupled%n_step,SP%export_planar)

           call tic(sc)

           if (SP%solveEnergy)    call solve(nrg,mom%U,  PE,DT)
           if (SP%solveMomentum)  call solve(mom,F,      PE,DT)
           if (SP%solveInduction) call solve(ind,mom%U_E,PE,DT)

           ! Q-2D implementation:
           ! call assign_negative(F%x,mom%U%x); call multiply(F%x,1.0_cp/(mom%Re/mom%Ha))
           ! call assign_negative(F%y,mom%U%y); call multiply(F%y,1.0_cp/(mom%Re/mom%Ha))
           ! call assign(F%z,0.0_cp)

           ! call assign(F,0.0_cp)

           if (SP%addJCrossB) then
             call compute_AddJCrossB(F,ind%B,ind%B0,ind%J,ind%m,&
                                     ind%D_fluid,mom%Ha,mom%Re,&
                                     ind%finite_Rem,ind%temp_CC_SF,&
                                     ind%temp_F1,ind%temp_F1_TF,&
                                     ind%temp_F2_TF,mom%temp_F)
           endif
           if (SP%addBuoyancy) then
             call compute_AddBuoyancy(F,nrg%T,nrg%gravity,&
                                      mom%Gr,mom%Re,nrg%m,nrg%D,&
                                      nrg%temp_F,nrg%temp_CC1_VF,mom%temp_F)
           endif
           if (SP%addGravity) then
             call compute_AddGravity(F,nrg%gravity,mom%Fr,nrg%m,&
                                     nrg%D,nrg%temp_F,nrg%temp_CC1_VF,&
                                     mom%temp_F)
           endif

           call iterate_step(coupled)
           call toc(sc)
           if (PE%info) then
             ! oldest_modified_file violates intent, but this 
             ! would be better to update outside the solvers.
             ! call oldest_modified_file(DT%restart,DT%restart1,DT%restart2,'p.dat')
             call print(sc)
             if (SP%solveMomentum) then
               call import(mom%TMP)
               call import(mom%ISP_U)
               call import(mom%ISP_P); call init(mom%PCG_P%ISP,mom%ISP_P)
             endif
             if (SP%solveInduction) then
               call import(ind%TMP)
               call import(ind%ISP_B); call init(ind%PCG_B%ISP,ind%ISP_B)
               call import(ind%ISP_phi); call init(ind%PCG_cleanB%ISP,ind%ISP_phi)
             endif
             if (SP%solveEnergy) then; call import(nrg%TMP)
                                       call import(nrg%ISP_T)
             endif

             continueLoop = readSwitchFromFile(str(DT%params),'killSwitch')
             call writeSwitchToFile(.false.,str(DT%params),'exportNow')
             write(*,*) 'Working directory = ',str(DT%tar)
             if (.not.continueLoop) then; call toc(sc); exit; endif
           endif
         enddo
         call print(sc)
         call export(sc,str(DT%LDC))
         ! ***************************************************************
         ! ********** FINISHED SOLVING MHD EQUATIONS *********************
         ! ***************************************************************
         call writeLastStepToFile(coupled%n_step,str(DT%params),'n_step')
         call writeLastStepToFile(nrg%TMP%n_step,str(DT%params),'nstep_nrg')
         call writeLastStepToFile(mom%TMP%n_step,str(DT%params),'nstep_mom')
         call writeLastStepToFile(ind%TMP%n_step,str(DT%params),'nstep_ind')

         call export(coupled)

         ! **************** EXPORT ONE FINAL TIME ***********************
         if (SP%solveMomentum)  call exportTransient(mom)
         if (SP%solveInduction) call exportTransient(ind)

         if (SP%solveEnergy) then;    call export_tec(nrg,DT);   endif ! call export(nrg,DT); endif
         if (SP%solveInduction) then; call export_tec(ind,DT);   endif ! call export(ind,DT); endif
         if (SP%solveMomentum) then;  call export_tec(mom,DT,F); endif ! call export(mom,DT); endif

         call delete(F)
       end subroutine

       end module