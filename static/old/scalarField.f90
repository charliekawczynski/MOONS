      module scalarField_mod
        ! Rules:
        ! a = a + b => call add(a,b)
        ! a = a - b => call subtract(a,b)
        ! a = a * b => call multiply(a,b)
        ! a = a / b => call divide(a,b)
        ! a = b / a => call divide(b,a)
        ! OR
        ! c = a + b => call add(c,a,b)
        ! c = a - b => call subtract(c,a,b)
        ! c = a * b => call multiply(c,a,b)
        ! c = a / b => call divide(c,a,b)
        ! c = b / a => call divide(c,b,a)

        ! Available pre-processor directives:
        !         _DEBUG_FIELD_ ! not yet implemented
        !         _PARALLELIZE_SCALAR_FIELD_

        implicit none
        private

        public :: scalarField
        public :: allocateField

        ! Optimized for readability:
        public :: assignment(=)               ! Causes segfault on hoffman
        public :: operator(+),operator(-)     ! Causes segfault on hoffman
        public :: operator(*),operator(/)     ! Causes segfault on hoffman

        ! Optimized for speed:
        public :: assign,delete
        public :: add,subtract
        public :: multiply,divide
        public :: square

        public :: printScalarField
        public :: checkScalarField

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

        type scalarField
          integer,dimension(3) :: s
          real(cp),dimension(:,:,:),allocatable :: phi
        end type

      interface allocateField
        module procedure allocateField1
        module procedure allocateField2
        module procedure allocateField3
      end interface

      interface delete
        module procedure deallocateField
      end interface

      ! Operators (optimized for readability)

      interface assignment (=)
        module procedure scalarAssignOp
        module procedure fieldFieldAssignOp
        module procedure fieldRealAssignOp
      end interface

      interface operator (+)
        module procedure fieldFieldAddOp
        module procedure fieldScalarAddOp
        module procedure scalarFieldAddOp
      end interface

      interface operator (-)
        module procedure fieldFieldSubtractOp
        module procedure fieldScalarSubtractOp
        module procedure scalarFieldSubtractOp
      end interface

      interface operator (*)
        module procedure fieldFieldMultiplyOp
        module procedure fieldScalarMultiplyOp
        module procedure scalarFieldMultiplyOp
      end interface

      interface operator (/)
        module procedure fieldFieldDivideOp
        module procedure fieldScalarDivideOp
        module procedure scalarFieldDivideOp
      end interface

      ! Operators (optimized for speed)

      interface assign
        module procedure scalarAssign
        module procedure fieldFieldAssign
        module procedure fieldRealAssign
      end interface

      interface add
        module procedure fieldFieldAdd
        module procedure fieldRealAdd
        module procedure fieldScalarAdd
        module procedure scalarFieldAdd
      end interface

      interface subtract
        module procedure fieldFieldSubtract
        module procedure fieldFieldSubtract2
        module procedure fieldScalarSubtract
        module procedure scalarFieldSubtract
      end interface

      interface multiply
        module procedure fieldFieldMultiply
        module procedure fieldFieldMultiply2
        module procedure fieldScalarMultiply
        module procedure scalarFieldMultiply
      end interface

      interface divide
        module procedure fieldFieldDivide
        module procedure fieldFieldDivide2
        module procedure fieldScalarDivide
        module procedure scalarFieldDivide
      end interface

      interface square
        module procedure squareScalarField
      end interface


      contains

        ! ***************** OPERATORS OPTIMIZED FOR READABILITY ************
        ! ----------------- ASSIGN ------------------

        subroutine scalarAssignOp(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
          f%phi = g
        end subroutine

        subroutine fieldFieldAssignOp(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
          f%phi = g%phi
          f%s = g%s
        end subroutine

        subroutine fieldRealAssignOp(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),dimension(:,:,:),intent(in) :: g
          f%phi = g
          f%s = shape(g)
        end subroutine

      ! ------------------- ADD ------------------------

        function fieldFieldAddOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          type(scalarField),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi + g%phi
          q%s = f%s
        end function

        function fieldScalarAddOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi + g
          q%s = f%s
        end function
        function scalarFieldAddOp(g,f) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi + g
          q%s = f%s
        end function

      ! ------------------- SUBTRACT ------------------------

        function fieldFieldSubtractOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          type(scalarField),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi - g%phi
          q%s = f%s
        end function

        function fieldScalarSubtractOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi - g
          q%s = f%s
        end function
        function scalarFieldSubtractOp(g,f) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = g - f%phi
          q%s = f%s
        end function

      ! ------------------- MULTIPLY ------------------------

        function fieldFieldMultiplyOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          type(scalarField),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi*g%phi
          q%s = f%s
        end function

        function fieldScalarMultiplyOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi*g
          q%s = f%s
        end function
        function scalarFieldMultiplyOp(g,f) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi*g
          q%s = f%s
        end function

      ! ------------------- DIVIDE ------------------------

        function fieldFieldDivideOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          type(scalarField),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi/g%phi
          q%s = f%s
        end function

        function fieldScalarDivideOp(f,g) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = f%phi/g
          q%s = f%s
        end function
        function scalarFieldDivideOp(g,f) result(q)
          implicit none
          type(scalarField),intent(in) :: f
          real(cp),intent(in) :: g
          type(scalarField) :: q
          q%phi = g/f%phi
          q%s = f%s
        end function

        ! ***************** OPERATORS OPTIMIZED FOR SPEED ************

        subroutine fieldFieldAssign(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g%phi
#endif
        end subroutine

        subroutine fieldRealAssign(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),dimension(:,:,:),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g
#endif
        end subroutine

        subroutine scalarAssign(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g
#endif
        end subroutine

      ! ------------------- ADD ------------------------

        subroutine fieldFieldAdd(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) + g%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi + g%phi
#endif
        end subroutine

        subroutine fieldRealAdd(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),dimension(:,:,:),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) + g(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi + g
#endif
        end subroutine

        subroutine fieldScalarAdd(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) + g
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi + g
#endif
        end subroutine
        subroutine scalarFieldAdd(g2,f)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g2
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) + g2
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi + g2
#endif
        end subroutine

      ! ------------------- SUBTRACT ------------------------

        subroutine fieldFieldSubtract(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) - g%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi - g%phi
#endif
        end subroutine

        subroutine fieldFieldSubtract2(f,g,q)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g,q
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g%phi(i,j,k) - q%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g%phi - q%phi
#endif
        end subroutine

        subroutine fieldScalarSubtract(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) - g
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi - g
#endif
        end subroutine
        subroutine scalarFieldSubtract(g2,f)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g2
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g2 - f%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g2 - f%phi
#endif
        end subroutine

      ! ------------------- MULTIPLY ------------------------

        subroutine fieldFieldMultiply(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) * g%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi * g%phi
#endif
        end subroutine

        subroutine fieldFieldMultiply2(f,g,q)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g,q
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g%phi(i,j,k) * q%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g%phi * q%phi
#endif
        end subroutine

        subroutine fieldScalarMultiply(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) * g
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi * g
#endif
        end subroutine
        subroutine scalarFieldMultiply(g2,f)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g2
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) * g2
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi * g2
#endif
        end subroutine

      ! ------------------- DIVIDE ------------------------

        subroutine fieldFieldDivide(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) / g%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi / g%phi
#endif
        end subroutine

        subroutine fieldFieldDivide2(f,g,q)
          implicit none
          type(scalarField),intent(inout) :: f
          type(scalarField),intent(in) :: g,q
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g%phi(i,j,k) / q%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g%phi / q%phi
#endif
        end subroutine

        subroutine fieldScalarDivide(f,g)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) / g
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi / g
#endif
        end subroutine
        subroutine scalarFieldDivide(g2,f)
          implicit none
          type(scalarField),intent(inout) :: f
          real(cp),intent(in) :: g2
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = g2 / f%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = g2 / f%phi
#endif
        end subroutine

        subroutine squareScalarField(f)
          implicit none
          type(scalarField),intent(inout) :: f
#ifdef _PARALLELIZE_SCALAR_FIELD_
          integer :: i,j,k
          !$OMP PARALLEL DO
          do k=1,f%s(3)
            do j=1,f%s(2)
              do i=1,f%s(1)
                f%phi(i,j,k) = f%phi(i,j,k) * f%phi(i,j,k)
              enddo
            enddo
          enddo
          !$OMP END PARALLEL DO
#else
          f%phi = f%phi*f%phi
#endif
        end subroutine

      ! ------------------- ALLOCATE / DEALLOCATE --------------------

        subroutine allocateField1(field,Nx,Ny,Nz)
          implicit none
          type(scalarField),intent(inout) :: field
          integer,intent(in) :: Nx,Ny,Nz
          if (allocated(field%phi)) deallocate(field%phi)
          allocate(field%phi(Nx,Ny,Nz))
          field%s = shape(field%phi)
        end subroutine

        subroutine allocateField2(field1,field2)
          implicit none
          type(scalarField),intent(inout) :: field1
          type(scalarField),intent(in) :: field2
          integer,dimension(3) :: s
          s = shape(field2%phi)
          if (allocated(field1%phi)) deallocate(field1%phi)
          allocate(field1%phi(s(1),s(2),s(3)))
          field1%s = shape(field1%phi)
        end subroutine

        subroutine allocateField3(field,s)
          implicit none
          type(scalarField),intent(inout) :: field
          integer,dimension(3),intent(in) :: s
          if (allocated(field%phi)) deallocate(field%phi)
          allocate(field%phi(s(1),s(2),s(3)))
          field%s = shape(field%phi)
        end subroutine

        subroutine deallocateField(field)
          implicit none
          type(scalarField),intent(inout) :: field
          if (allocated(field%phi)) deallocate(field%phi)
          field%s = 0
        end subroutine

        subroutine checkScalarField(field,name)
          implicit none
          type(scalarField),intent(in) :: field
          character(len=*),intent(in) :: name
          write(*,*) 'Field info for: ',name
          if (allocated(field%phi)) then
                write(*,*) 'phi allocated, s = ',field%s
          else; write(*,*) 'phi NOT allocated'
          endif
        end subroutine

        subroutine printScalarField(field)
          implicit none
          type(scalarField),intent(in) :: field
          integer :: i,j,k
          if (allocated(field%phi))   then
            write(*,*) 'shape(phi) = ',field%s
            do i=1,field%s(1)
              do j=1,field%s(2)
                do k=1,field%s(3)
                  write(*,'(A4,I1,A,I1,A,I1,A4,1F15.6)') 'phi(',i,',',j,',',k,') = ',field%phi(i,j,k)
                enddo
              enddo
            enddo
          endif
        end subroutine

      end module