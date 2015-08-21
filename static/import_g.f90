      module import_g_mod
      ! This module, along with exportRaw.f90 provide purely functional 
      ! pipeline routines to export data given inputs. The possible grid types
      ! can be checked in the getType_3D,getType_2D,getType_1D routines.
      ! 
      use import_raw_mod
      use grid_mod
      implicit none

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

      private

      public :: imp_3D_3C_g,imp_3D_2C_g,imp_3D_1C_g ! 3D Fields
      public :: imp_2D_3C_g,imp_2D_2C_g,imp_2D_1C_g ! 2D Fields
      public :: imp_1D_3C_g,imp_1D_2C_g,imp_1D_1C_g ! 1D Fields

      public :: getType_3D,getType_2D,getType_1D    ! getDataType

      ! public :: getType
      ! interface getType;  module procedure getType_1D; end interface
      ! interface getType;  module procedure getType_2D; end interface
      ! interface getType;  module procedure getType_3D; end interface

      contains

      ! ***********************************************************************
      ! ***********************************************************************
      ! ****************************** 3D FIELDS ******************************
      ! ***********************************************************************
      ! ***********************************************************************

      subroutine imp_3D_3C_g(g,DT,pad,un,arrfmt,s,u,v,w)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: u,v,w
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un
        integer,dimension(3),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        select case (DT)
        case (1); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hn,u,v,w)
        case (2); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hc,u,v,w)
        case (3); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hc,u,v,w)
        case (4); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hc,u,v,w)
        case (5); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hn,u,v,w)
        case (6); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hn,u,v,w)
        case (7); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hn,u,v,w)
        case (8); call imp_3D_3C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hc,u,v,w)
        end select
      end subroutine

      subroutine imp_3D_2C_g(g,DT,pad,un,arrfmt,s,u,v)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: u,v
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un
        integer,dimension(3),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        select case (DT)
        case (1); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hn,u,v)
        case (2); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hc,u,v)
        case (3); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hc,u,v)
        case (4); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hc,u,v)
        case (5); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hn,u,v)
        case (6); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hn,u,v)
        case (7); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hn,u,v)
        case (8); call imp_3D_2C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hc,u,v)
        end select
      end subroutine

      subroutine imp_3D_1C_g(g,DT,pad,un,arrfmt,s,u)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: u
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un
        integer,dimension(3),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        select case (DT)
        case (1); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hn,u)
        case (2); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hc,u)
        case (3); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hc,u)
        case (4); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hc,u)
        case (5); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hc,g%c(3)%hn,u)
        case (6); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hc,g%c(2)%hn,g%c(3)%hn,u)
        case (7); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hc,g%c(3)%hn,u)
        case (8); call imp_3D_1C(s,pad,un,arrfmt,g%c(1)%hn,g%c(2)%hn,g%c(3)%hc,u)
        end select
      end subroutine

      ! ***********************************************************************
      ! ***********************************************************************
      ! ****************************** 2D FIELDS ******************************
      ! ***********************************************************************
      ! ***********************************************************************

      subroutine imp_2D_3C_g(g,DT,pad,un,arrfmt,s,axis,u,v,w)
        implicit none
        real(cp),dimension(:,:),intent(inout) :: u,v,w
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(2),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        integer,dimension(2) :: d
        select case (axis)
        case (1); d = (/2,3/); case (2); d = (/1,3/); case (3); d = (/1,2/)
        case default; stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        end select
        select case (DT)
        case (1); call imp_2D_3C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hn,u,v,w)
        case (2); call imp_2D_3C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hc,u,v,w)
        case (3); call imp_2D_3C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hc,u,v,w)
        case (4); call imp_2D_3C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hn,u,v,w)
        end select
      end subroutine

      subroutine imp_2D_2C_g(g,DT,pad,un,arrfmt,s,axis,u,v)
        implicit none
        real(cp),dimension(:,:),intent(inout) :: u,v
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(2),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        integer,dimension(2) :: d
        select case (axis)
        case (1); d = (/2,3/); case (2); d = (/1,3/); case (3); d = (/1,2/)
        case default; stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        end select
        select case (DT)
        case (1); call imp_2D_2C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hn,u,v)
        case (2); call imp_2D_2C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hc,u,v)
        case (3); call imp_2D_2C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hc,u,v)
        case (4); call imp_2D_2C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hn,u,v)
        end select
      end subroutine

      subroutine imp_2D_1C_g(g,DT,pad,un,arrfmt,s,axis,u)
        implicit none
        real(cp),dimension(:,:),intent(inout) :: u
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(2),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        integer,dimension(2) :: d
        select case (axis)
        case (1); d = (/2,3/); case (2); d = (/1,3/); case (3); d = (/1,2/)
        case default; stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        end select
        select case (DT)
        case (1); call imp_2D_1C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hn,u)
        case (2); call imp_2D_1C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hc,u)
        case (3); call imp_2D_1C(s,pad,un,arrfmt,g%c(d(1))%hn,g%c(d(2))%hc,u)
        case (4); call imp_2D_1C(s,pad,un,arrfmt,g%c(d(1))%hc,g%c(d(2))%hn,u)
        end select
      end subroutine

      ! ***********************************************************************
      ! ***********************************************************************
      ! ****************************** 1D FIELDS ******************************
      ! ***********************************************************************
      ! ***********************************************************************

      subroutine imp_1D_3C_g(g,DT,pad,un,arrfmt,s,axis,u,v,w)
        implicit none
        real(cp),dimension(:),intent(inout) :: u,v,w
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(1),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        if (.not.any((/axis.eq.(/1,2,3/)/))) stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        select case (DT)
        case (1); call imp_1D_3C(s,pad,un,arrfmt,g%c(axis)%hn,u,v,w)
        case (2); call imp_1D_3C(s,pad,un,arrfmt,g%c(axis)%hc,u,v,w)
        end select
      end subroutine

      subroutine imp_1D_2C_g(g,DT,pad,un,arrfmt,s,axis,u,v)
        implicit none
        real(cp),dimension(:),intent(inout) :: u,v
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(1),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        if (.not.any((/axis.eq.(/1,2,3/)/))) stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        select case (DT)
        case (1); call imp_1D_2C(s,pad,un,arrfmt,g%c(axis)%hn,u,v)
        case (2); call imp_1D_2C(s,pad,un,arrfmt,g%c(axis)%hc,u,v)
        end select
      end subroutine

      subroutine imp_1D_1C_g(g,DT,pad,un,arrfmt,s,axis,u)
        implicit none
        real(cp),dimension(:),intent(inout) :: u
        type(grid),intent(inout) :: g
        integer,intent(in) :: DT,pad,un,axis
        integer,dimension(1),intent(in) :: s
        character(len=*),intent(in) :: arrfmt
        if (.not.any((/axis.eq.(/1,2,3/)/))) stop 'Error: axis must = 1,2,3 in imp_2D_2Cg in export.f90'
        select case (DT)
        case (1); call imp_1D_1C(s,pad,un,arrfmt,g%c(axis)%hn,u)
        case (2); call imp_1D_1C(s,pad,un,arrfmt,g%c(axis)%hc,u)
        end select
      end subroutine

      ! ***********************************************************************
      ! ***********************************************************************
      ! ********************** DATA TYPE DEFINITIONS **************************
      ! ***********************************************************************
      ! ***********************************************************************

      function getType_3D(g,s,name) result(DT)
        implicit none
        type(grid),intent(in) :: g
        integer,dimension(3),intent(in) :: s
        character(len=*),intent(in) :: name
        integer :: DT
            if (all(s.eq.(/g%c(1)%sn,g%c(2)%sn,g%c(3)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sc,g%c(3)%sc/))) then; DT = 2 ! CC data
        elseif (all(s.eq.(/g%c(1)%sn,g%c(2)%sc,g%c(3)%sc/))) then; DT = 3 ! Face data x
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sn,g%c(3)%sc/))) then; DT = 4 ! Face data y
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sc,g%c(3)%sn/))) then; DT = 5 ! Face data z
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sn,g%c(3)%sn/))) then; DT = 6 ! Edge Data x
        elseif (all(s.eq.(/g%c(1)%sn,g%c(2)%sc,g%c(3)%sn/))) then; DT = 7 ! Edge Data y
        elseif (all(s.eq.(/g%c(1)%sn,g%c(2)%sn,g%c(3)%sc/))) then; DT = 8 ! Edge Data z
        else
          write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'
          stop 'Done'
        endif
      end function

      function getType_2D(g,s,name,axis) result(DT)
        implicit none
        type(grid),intent(in) :: g
        integer,dimension(2),intent(in) :: s
        integer,intent(in) :: axis
        character(len=*),intent(in) :: name
        integer :: DT
        select case (axis)
        case (1)
            if (all(s.eq.(/g%c(2)%sn,g%c(3)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(2)%sc,g%c(3)%sc/))) then; DT = 2 ! CC data
        elseif (all(s.eq.(/g%c(2)%sn,g%c(3)%sc/))) then; DT = 3 ! Face data y
        elseif (all(s.eq.(/g%c(2)%sc,g%c(3)%sn/))) then; DT = 4 ! Face data z
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case (2)
            if (all(s.eq.(/g%c(1)%sn,g%c(3)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(1)%sc,g%c(3)%sc/))) then; DT = 2 ! CC data
        elseif (all(s.eq.(/g%c(1)%sn,g%c(3)%sc/))) then; DT = 3 ! Face data x
        elseif (all(s.eq.(/g%c(1)%sc,g%c(3)%sn/))) then; DT = 4 ! Face data z
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case (3)
            if (all(s.eq.(/g%c(1)%sn,g%c(2)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sc/))) then; DT = 2 ! CC data
        elseif (all(s.eq.(/g%c(1)%sn,g%c(2)%sc/))) then; DT = 3 ! Face data x
        elseif (all(s.eq.(/g%c(1)%sc,g%c(2)%sn/))) then; DT = 4 ! Face data y
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case default
          write(*,*) 'Error: axis must = 1,2,3 for '//name//' in dataSet.f90.'; stop 'Done'
        end select
      end function

      function getType_1D(g,s,name,axis) result(DT)
        implicit none
        type(grid),intent(in) :: g
        integer,dimension(1),intent(in) :: s
        integer,intent(in) :: axis
        character(len=*),intent(in) :: name
        integer :: DT
        select case (axis)
        case (1)
            if (all(s.eq.(/g%c(1)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(1)%sc/))) then; DT = 2 ! CC data
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case (2)
            if (all(s.eq.(/g%c(2)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(2)%sc/))) then; DT = 2 ! CC data
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case (3)
            if (all(s.eq.(/g%c(3)%sn/))) then; DT = 1 ! Node data
        elseif (all(s.eq.(/g%c(3)%sc/))) then; DT = 2 ! CC data
        else; write(*,*) 'Error: grid-field mismatch with '//name//' in dataSet.f90.'; stop 'Done'
        endif
        case default
          write(*,*) 'Error: axis must = 1,2,3 for '//name//' in dataSet.f90.'; stop 'Done'
        end select
      end function

      end module