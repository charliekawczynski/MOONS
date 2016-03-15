      module ops_del_mod
      ! Returns an n-derivative of the scalar field, f, 
      ! along direction dir (1,2,3) which corresponds to (x,y,z).
      ! 
      ! Flags: (fopenmp,_DEBUG_DEL_)
      ! 
      ! Implementation:
      !      type(del) :: d
      !      type(SF) :: f,dfdh
      !      type(mesh) :: m
      !      integer :: n,dir,pad
      !      call d%assign  (dfdh,f,m,n,dir,pad) --> dfdh = d/dh (f), 0 if not defined.
      !      call d%add     (dfdh,f,m,n,dir,pad) --> dfdh = dfdh + d/dh (f)
      !      call d%subtract(dfdh,f,m,n,dir,pad) --> dfdh = dfdh - d/dh (f)
      ! 
      ! INPUT:
      !     f            = f(x,y,z)
      !     m            = mesh containing grids
      !     n            = nth derivative (n=1,2 supported)
      !     dir          = direction along which to take the derivative (1,2,3)
      !     pad          = (1,0) = (exclude,include) boundary calc along derivative direction
      !                    |0000000|     |-------|
      !                    |-------|  ,  |-------| Look at del for implementation details  
      !                    |0000000|     |-------|
      !
      ! CharlieKawczynski@gmail.com
      ! 5/15/2014

      use grid_mod
      use face_edge_corner_indexing_mod
      use mesh_mod
      use SF_mod
      use triDiag_mod
      use stencils_mod
      use apply_stitches_mod
      implicit none

      private
      public :: del 

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

      type del
        contains
        generic,public :: assign => assignDel
        generic,public :: add => addDel
        generic,public :: subtract => subtractDel
        procedure,private,nopass :: assignDel
        procedure,private,nopass :: addDel
        procedure,private,nopass :: subtractDel
      end type

      contains

      ! *********************************************************
      ! *********************** LOW LEVEL ***********************
      ! *********************************************************

      subroutine diff_stag(operator,dfdh,f,T,dir,pad,gt,s,sdfdh)
        implicit none
        external :: operator
        real(cp),dimension(:,:,:),intent(inout) :: dfdh
        real(cp),dimension(:,:,:),intent(in) :: f
        type(triDiag),intent(in) :: T
        integer,intent(in) :: dir,pad,gt
        integer,dimension(3),intent(in) :: s,sdfdh
        integer :: i,j,k
        select case (dir)
        case (1)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,sdfdh,gt)

#endif
        do k=1+pad,s(3)-pad; do j=1+pad,s(2)-pad
          call operator(dfdh(:,j,k),f(:,j,k),T,s(1),sdfdh(1),gt)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case (2)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,sdfdh,gt)

#endif
        do k=1+pad,s(3)-pad; do i=1+pad,s(1)-pad
          call operator(dfdh(i,:,k),f(i,:,k),T,s(2),sdfdh(2),gt)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case (3)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,sdfdh,gt)

#endif
        do j=1+pad,s(2)-pad; do i=1+pad,s(1)-pad
          call operator(dfdh(i,j,:),f(i,j,:),T,s(3),sdfdh(3),gt)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case default
        stop 'Error: dir must = 1,2,3 in delGen_T in ops_del.f90.'
        end select
      end subroutine

      subroutine diff_col(operator,dfdh,f,T,dir,pad,s,pad1,pad2)
        implicit none
        external :: operator
        real(cp),dimension(:,:,:),intent(inout) :: dfdh
        real(cp),dimension(:,:,:),intent(in) :: f
        type(triDiag),intent(in) :: T
        integer,intent(in) :: dir,pad,pad1,pad2
        integer,dimension(3),intent(in) :: s
        integer :: i,j,k
        select case (dir)
        case (1)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,pad1,pad2)

#endif
        do k=1+pad,s(3)-pad; do j=1+pad,s(2)-pad
          call operator(dfdh(:,j,k),f(:,j,k),T,s(1),pad1,pad2)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case (2)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,pad1,pad2)

#endif
        do k=1+pad,s(3)-pad; do i=1+pad,s(1)-pad
          call operator(dfdh(i,:,k),f(i,:,k),T,s(2),pad1,pad2)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case (3)
#ifdef _PARALLELIZE_DEL_
        !$OMP PARALLEL DO SHARED(T,s,pad1,pad2)

#endif
        do j=1+pad,s(2)-pad; do i=1+pad,s(1)-pad
          call operator(dfdh(i,j,:),f(i,j,:),T,s(3),pad1,pad2)
        enddo; enddo
#ifdef _PARALLELIZE_DEL_
        !$OMP END PARALLEL DO

#endif
        case default
        stop 'Error: dir must = 1,2,3 in delGen_T in ops_del.f90.'
        end select
      end subroutine


      ! *********************************************************
      ! *********************** MED LEVEL ***********************
      ! *********************************************************

      subroutine diff_tree_search(dfdh,f,g,n,dir,pad,genType,s,sdfdh,diffType,pad1,pad2)
        implicit none
        real(cp),dimension(:,:,:),intent(inout) :: dfdh
        real(cp),dimension(:,:,:),intent(in) :: f
        type(grid),intent(in) :: g
        integer,intent(in) :: n,dir,pad,genType,pad1,pad2
        integer,dimension(3),intent(in) :: s,sdfdh
        integer,intent(in) :: diffType
        select case (genType)
        case (1); select case (diffType)
                  case (1); call diff_col(col_CC_assign,dfdh,f,g%c(dir)%colCC(n),dir,pad,s,pad1,pad2)
                  case (2); call diff_col(col_N_assign ,dfdh,f,g%c(dir)%colN(n) ,dir,pad,s,pad1,pad2)
                  case (3); call diff_stag(stag_assign ,dfdh,f,g%c(dir)%stagCC2N,dir,pad,1,s,sdfdh)
                  case (4); call diff_stag(stag_assign ,dfdh,f,g%c(dir)%stagN2CC,dir,pad,0,s,sdfdh)
                  end select
        case (2); select case (diffType)
                  case (1); call diff_col(col_CC_add,dfdh,f,g%c(dir)%colCC(n),dir,pad,s,pad1,pad2)
                  case (2); call diff_col(col_N_add ,dfdh,f,g%c(dir)%colN(n) ,dir,pad,s,pad1,pad2)
                  case (3); call diff_stag(stag_add ,dfdh,f,g%c(dir)%stagCC2N,dir,pad,1,s,sdfdh)
                  case (4); call diff_stag(stag_add ,dfdh,f,g%c(dir)%stagN2CC,dir,pad,0,s,sdfdh)
                  end select
        case (3); select case (diffType)
                  case (1); call diff_col(col_CC_subtract,dfdh,f,g%c(dir)%colCC(n),dir,pad,s,pad1,pad2)
                  case (2); call diff_col(col_N_subtract ,dfdh,f,g%c(dir)%colN(n) ,dir,pad,s,pad1,pad2)
                  case (3); call diff_stag(stag_subtract ,dfdh,f,g%c(dir)%stagCC2N,dir,pad,1,s,sdfdh)
                  case (4); call diff_stag(stag_subtract ,dfdh,f,g%c(dir)%stagN2CC,dir,pad,0,s,sdfdh)
                  end select
        case default
        stop 'Error: genType must = 1,2,3 in ops_del.f90'
        end select

        if (genType.eq.1) then
          if (pad.gt.0) then
            select case (dir)
          case (1); dfdh(:,:,1) = 0.0_cp; dfdh(:,:,sdfdh(3)) = 0.0_cp
                    dfdh(:,1,:) = 0.0_cp; dfdh(:,sdfdh(2),:) = 0.0_cp
          case (2); dfdh(1,:,:) = 0.0_cp; dfdh(sdfdh(1),:,:) = 0.0_cp
                    dfdh(:,:,1) = 0.0_cp; dfdh(:,:,sdfdh(3)) = 0.0_cp
          case (3); dfdh(1,:,:) = 0.0_cp; dfdh(sdfdh(1),:,:) = 0.0_cp
                    dfdh(:,1,:) = 0.0_cp; dfdh(:,sdfdh(2),:) = 0.0_cp
          case default
            stop 'Error: dir must = 1,2,3 in delGen_T in ops_del.f90.'
            end select
          endif
        endif

#ifdef _DEBUG_DEL_
        call checkSideDimensions(s,sdfdh,dir)
#endif
      end subroutine

      subroutine diff(dfdh,f,m,n,dir,pad,genType)
        implicit none
        type(SF),intent(inout) :: dfdh
        type(SF),intent(in) :: f
        type(mesh),intent(in) :: m
        integer,intent(in) :: n,dir,pad,genType
        integer :: i,pad1,pad2,diffType
        integer,dimension(2) :: faces

        diffType = getDiffType(f,dfdh,dir)
        do i=1,m%s
          faces = normal_faces_given_dir(dir)
          if (m%g(i)%st_faces(faces(1))%TF) then; pad1 = 1; else; pad1 = 0; endif
          if (m%g(i)%st_faces(faces(2))%TF) then; pad2 = 1; else; pad2 = 0; endif
          call diff_tree_search(dfdh%RF(i)%f,f%RF(i)%f,m%g(i),&
            n,dir,pad,genType,f%RF(i)%s,dfdh%RF(i)%s,diffType,pad1,pad2)
        enddo
        call apply_stitches(dfdh,m)
      end subroutine

      ! *********************************************************
      ! *********************** HIGH LEVEL **********************
      ! *********************************************************

      subroutine assignDel(dfdh,f,m,n,dir,pad)
        implicit none
        type(SF),intent(inout) :: dfdh
        type(SF),intent(in) :: f
        type(mesh),intent(in) :: m
        integer,intent(in) :: n,dir,pad
        call diff(dfdh,f,m,n,dir,pad,1)
      end subroutine

      subroutine addDel(dfdh,f,m,n,dir,pad)
        implicit none
        type(SF),intent(inout) :: dfdh
        type(SF),intent(in) :: f
        type(mesh),intent(in) :: m
        integer,intent(in) :: n,dir,pad
        call diff(dfdh,f,m,n,dir,pad,2)
      end subroutine

      subroutine subtractDel(dfdh,f,m,n,dir,pad)
        implicit none
        type(SF),intent(inout) :: dfdh
        type(SF),intent(in) :: f
        type(mesh),intent(in) :: m
        integer,intent(in) :: n,dir,pad
        call diff(dfdh,f,m,n,dir,pad,3)
      end subroutine

      ! *********************************************************
      ! *********************** AUX / DEBUG *********************
      ! *********************************************************

      function getDiffType(f,dfdh,dir) result(diffType)
        implicit none
        type(SF),intent(in) :: f,dfdh
        integer,intent(in) :: dir
        integer :: diffType
            if (CC_along(f,dir).and.CC_along(dfdh,dir)) then
          diffType = 1 ! Collocated derivative (CC)
        elseif (Node_along(f,dir).and.Node_along(dfdh,dir)) then
          diffType = 2 ! Collocated derivative (N)
        elseif (CC_along(f,dir).and.Node_along(dfdh,dir)) then
          diffType = 3 ! Staggered derivative (CC->N)
        elseif (Node_along(f,dir).and.CC_along(dfdh,dir)) then
          diffType = 4 ! Staggered derivative (N->CC)
        else
          write(*,*) 'CC_along(f,dir) = ',CC_along(f,dir)
          write(*,*) 'Node_along(f,dir) = ',Node_along(f,dir)
          write(*,*) 'CC_along(dfdh,dir) = ',CC_along(dfdh,dir)
          write(*,*) 'Node_along(dfdh,dir) = ',Node_along(dfdh,dir)
          write(*,*) 'dir = ',dir
          stop 'Error: diffType undetermined in ops_del.f90.'
        endif
      end function

#ifdef _DEBUG_DEL_
      subroutine checkSideDimensions(s1,s2,dir)
        ! This routine makes sure that the shapes s1 and s2 
        ! are equal for orthogonal directions to dir, which
        ! must be the case for all derivatives in del.
        implicit none
        integer,dimension(3),intent(in) :: s1,s2
        integer,intent(in) :: dir
        select case (dir)
        case (1); if (s1(2).ne.s2(2)) stop 'Error: Shape mismatch 1 in checkSideDimensions in ops_del.f90'
                  if (s1(3).ne.s2(3)) stop 'Error: Shape mismatch 2 in checkSideDimensions in ops_del.f90'
        case (2); if (s1(1).ne.s2(1)) stop 'Error: Shape mismatch 3 in checkSideDimensions in ops_del.f90'
                  if (s1(3).ne.s2(3)) stop 'Error: Shape mismatch 4 in checkSideDimensions in ops_del.f90'
        case (3); if (s1(1).ne.s2(1)) stop 'Error: Shape mismatch 5 in checkSideDimensions in ops_del.f90'
                  if (s1(2).ne.s2(2)) stop 'Error: Shape mismatch 6 in checkSideDimensions in ops_del.f90'
        case default
        stop 'Error: dir must = 1,2,3 in ops_del.f90'
        end select
      end subroutine
#endif

      end module