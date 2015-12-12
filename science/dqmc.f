c Todd J. Minehardt 102299.
c Diffusion Monte Carlo, one electron in a cube.
c All units in atomic units.
      program mc
      parameter(tstep = 0.01)
      parameter(nmax = 2000)
      real x(nmax),y(nmax),z(nmax)
      real xprev(nmax),yprev(nmax),zprev(nmax)
      real dele(nmax),b(nmax)
      integer nm(nmax), t

c Definitions.

      pi = acos(-1.0)

c Set random seed based on system time.

      call system_clock(t)
      call srand(t)

c Number of initial walkers.

      m = 1000
      minit = m

c Number of steps per block.

      itotal = 500

c Number of blocks; the first is equilibration and will not be
c counted in the average.

      nblock = 11

c Total energy.

      esum = 0.0

c Initially, assign each walker random x,y, and z coordinates.

      do i = 1,m
        xprev(i) = rand() - 0.5
        yprev(i) = rand() - 0.5
        zprev(i) = rand() - 0.5
      enddo

c Loop for number of blocks.

      do iblock = 1,nblock
      eblock = 0.0

c Loop for number of moves.

      do iloop = 1,itotal

c Advance each walker's position.

      do i = 1,m
        chi = sqrt(-2.0 * log(rand())) * cos(pi*rand())
        x(i) = xprev(i) + chi*(tstep**0.5)
        chi = sqrt(-2.0 * log(rand())) * cos(pi*rand())
        y(i) = yprev(i) + chi*(tstep**0.5)
        chi = sqrt(-2.0 * log(rand())) * cos(pi*rand())
        z(i) = zprev(i) + chi*(tstep**0.5)
      enddo

c Now, compute old (ep) and new (en) energies.

      do i = 1,m
        ep = -1.0/sqrt(xprev(i)**2 + yprev(i)**2 + zprev(i)**2)
        en = -1.0/sqrt(x(i)**2 + y(i)**2 + z(i)**2)
        dele(i) = ep + en
      enddo

c For each walker, compute the branching probablility and average.

      bavg = 0.0
      do i = 1,m
        a = (-dele(i) * tstep)/2.0
        b(i) = exp(a)
        bavg = bavg + b(i)
      enddo
      bavg = bavg/m

c An estimate of the exact energy, summed over loops. 

      eblock = eblock - log(bavg)/tstep

c Now make nm copies of new coordinates.

      if (iloop.eq.1) then
        mprime = 0
          do i = 1,m
            nm(i) = int((b(i)/bavg) + rand())
            mprime = mprime + nm(i)
          enddo
      else
        mprime2 = 0
          do i = 1,mprime
            nm(i) = int((b(i)/bavg) * (m/mprime) + rand())
            mprime2 = mprime2 + nm(i)
          enddo
        mprime = mprime2
      endif

c Collapse the list.

      index = 0
      do i = 1,m
        if (nm(i).ne.0) then
          index = index + 1
          nm(index) = nm(i)
          x(index) = x(i)
          y(index) = y(i)
          z(index) = z(i)
        endif
      enddo

c Reorder.

      index = 0
      do i = 1,mprime
        if (nm(i).ne.0) then
          do k = 1,nm(i)
            xprev(k+index) = x(i)
            yprev(k+index) = y(i)
            zprev(k+index) = z(i)
          enddo
          index = index + nm(i)
        endif
      enddo
      m = mprime

c End loop for number of steps.

      enddo

      write(6,*)'End of block ', iblock, ' E(avg) = ', eblock/itotal

c Store ``equilibrated'' trajectories for total average.

      if (iblock.gt.1) then
      esum = esum + eblock/itotal
      endif

c End loop for blocks.

      enddo

      write(6,*)' # of initial walkers = ',minit
      write(6,*)' # of time steps per block = ',itotal
      write(6,*)' # of blocks = ',nblock
      write(6,*)'Calculated energy over the last', nblock-1,
     1          ' blocks = ', esum/(nblock-1)

      end
