      subroutine b_calc_pedestal(ABORT,err)

      implicit none
      save

      character*15 here
      parameter(here='b_calc_pedestal')

      logical ABORT
      character*(*) err

      include 'bigcal_data_structures.cmn'
      include 'bigcal_gain_parms.cmn'
      include 'bigcal_filenames.cmn'
      include 'gen_run_info.cmn'

      integer spareid
      parameter(spareid=67)

      integer irow,icol,icell
      integer igroup,ihalf,igr64

      integer nchange
      integer roc,slot,signalcount

      real numped,sigma2

      character*132 file

      nchange = 0

      do irow=1,BIGCAL_PROT_NY
         do icol=1,BIGCAL_PROT_NX
            icell = icol + (irow-1)*BIGCAL_PROT_NX
            numped = max(1.,float(bigcal_prot_ped_num(icell)))
            
            bigcal_prot_new_ped(icell)=bigcal_prot_ped_sum(icell)/numped
            sigma2=float(bigcal_prot_ped_sum2(icell))/numped - 
     $           (bigcal_prot_new_ped(icell))**2

            bigcal_prot_new_rms(icell) = sqrt(max(0.,sigma2))

            bigcal_prot_new_threshold(icell)=bigcal_prot_new_ped(icell)
     $           + 10.
            if(abs(bigcal_prot_ped_mean(icell) - 
     $           bigcal_prot_new_ped(icell)).gt. 2.0 *
     $           bigcal_prot_new_rms(icell)) then
               nchange = nchange + 1
               bigcal_prot_change_irow(nchange) = irow
               bigcal_prot_change_icol(nchange) = icol
               bigcal_prot_ped_change(nchange) = 
     $              bigcal_prot_new_ped(icell) - 
     $              bigcal_prot_ped_mean(icell)
            endif

            if(numped.gt.bigcal_prot_min_peds.and.bigcal_prot_min_peds
     $           .ne.0) then
               bigcal_prot_ped_mean(icell)=bigcal_prot_new_ped(icell)
               bigcal_prot_ped_rms(icell)=bigcal_prot_new_rms(icell)
               bigcal_prot_adc_threshold(icell)=min(50.,max(10.,3.*
     $              bigcal_prot_new_rms(icell)))
            endif
         enddo
      enddo

      bigcal_prot_num_ped_changes = nchange

      nchange = 0

      do irow=1,BIGCAL_RCS_NY
         do icol=1,BIGCAL_RCS_NX
            icell = icol + (irow-1)*BIGCAL_RCS_NX
            numped = max(1.,float(bigcal_rcs_ped_num(icell)))
            
            bigcal_rcs_new_ped(icell)=bigcal_rcs_ped_sum(icell)/numped
            sigma2=float(bigcal_rcs_ped_sum2(icell))/numped - 
     $           (bigcal_rcs_new_ped(icell))**2

            bigcal_rcs_new_rms(icell) = sqrt(max(0.,sigma2))

            bigcal_rcs_new_threshold(icell)=bigcal_rcs_new_ped(icell)
     $           + 10.
            if(abs(bigcal_rcs_ped_mean(icell) - 
     $           bigcal_rcs_new_ped(icell)).gt. 2.0 *
     $           bigcal_rcs_new_rms(icell)) then
               nchange = nchange + 1
               bigcal_rcs_change_irow(nchange) = irow
               bigcal_rcs_change_icol(nchange) = icol
               bigcal_rcs_ped_change(nchange) = 
     $              bigcal_rcs_new_ped(icell) - 
     $              bigcal_rcs_ped_mean(icell)
            endif

            if(numped.gt.bigcal_rcs_min_peds.and.bigcal_rcs_min_peds
     $           .ne.0) then
               bigcal_rcs_ped_mean(icell)=bigcal_rcs_new_ped(icell)
               bigcal_rcs_ped_rms(icell)=bigcal_rcs_new_rms(icell)
               bigcal_rcs_adc_threshold(icell)=min(50.,max(10.,3.*
     $              bigcal_rcs_new_rms(icell)))
            endif
         enddo
      enddo

      bigcal_rcs_num_ped_changes = nchange

      nchange = 0

      do igroup=1,BIGCAL_LOGIC_GROUPS/2
         do ihalf=1,2
            igr64 = igroup + (ihalf-1)*BIGCAL_LOGIC_GROUPS/2
            numped = max(1.,float(bigcal_trig_ped_num(igr64)))
            
            bigcal_trig_new_ped(igr64)=bigcal_trig_ped_sum(igr64)/numped
            sigma2=float(bigcal_trig_ped_sum2(igr64))/numped - 
     $           (bigcal_trig_new_ped(igr64))**2

            bigcal_trig_new_rms(igr64) = sqrt(max(0.,sigma2))

            bigcal_trig_new_threshold(igr64)=bigcal_trig_new_ped(igr64)
     $           + 10.
            if(abs(bigcal_trig_ped_mean(igr64) - 
     $           bigcal_trig_new_ped(igr64)).gt. 2.0 *
     $           bigcal_trig_new_rms(igr64)) then
               nchange = nchange + 1
               bigcal_trig_change_irow(nchange) = irow
               bigcal_trig_change_icol(nchange) = icol
               bigcal_trig_ped_change(nchange) = 
     $              bigcal_trig_new_ped(igr64) - 
     $              bigcal_trig_ped_mean(igr64)
            endif

            if(numped.gt.bigcal_trig_min_peds.and.bigcal_trig_min_peds
     $           .ne.0) then
               bigcal_trig_ped_mean(igr64)=bigcal_trig_new_ped(igr64)
               bigcal_trig_ped_rms(igr64)=bigcal_trig_new_rms(igr64)
               bigcal_trig_adc_threshold(igr64)=min(50.,max(10.,3.*
     $              bigcal_trig_new_rms(igr64)))
            endif
         enddo
      enddo

      bigcal_trig_num_ped_changes = nchange

c     now we write thresholds to file for hardware sparsification:

      if(b_threshold_output_filename.ne.' ') then
         file = b_threshold_output_filename
         call g_sub_run_number(file,gen_run_number)
         open(unit=SPAREID,file=file,status='unknown')

         write(SPAREID,*) '# This is the ADC threshold file generated 
     $        automatically'
         write(SPAREID,*) 'from the pedestal data, run #',gen_run_number

         roc=11
c     protvino ADCs are in ROC11, slots 3-10 and 14-21

         signalcount=1

         do slot=3,10
            write(spareid,*) 'slot=',slot
            call g_output_thresholds(spareid,roc,slot,signalcount,
     $           BIGCAL_PROT_NX,bigcal_prot_new_threshold,0,
     $           bigcal_prot_new_rms,0)
         enddo
            
         do slot=14,21
            write(spareid,*) 'slot=',slot
            call g_output_thresholds(spareid,roc,slot,signalcount,
     $           BIGCAL_PROT_NX,bigcal_prot_new_threshold,0,
     $           bigcal_prot_new_rms,0)
         enddo
c     trigger ADCs are in roc 11, slot 22
         slot=22
         write(spareid,*) 'slot=',slot
         call g_output_thresholds(spareid,roc,slot,signalcount,
     $        2,bigcal_trig_new_threshold,0,
     $        bigcal_trig_new_rms,0)

c     rcs ADCs are in ROC12, slots 6-11 and 15-20
         roc=12
         do slot=6,11
            write(spareid,*) 'slot=',slot
            call g_output_thresholds(spareid,roc,slot,signalcount,
     $           BIGCAL_RCS_NX,bigcal_rcs_new_threshold,0,
     $           bigcal_rcs_new_rms,0)
         enddo
         
         do slot=15,20
            write(spareid,*) 'slot=',slot
            call g_output_thresholds(spareid,roc,slot,signalcount,
     $           BIGCAL_RCS_NX,bigcal_rcs_new_threshold,0,
     $           bigcal_rcs_new_rms,0)
         enddo
      endif

      return
      end