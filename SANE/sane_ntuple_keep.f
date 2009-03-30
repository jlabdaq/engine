      subroutine sane_ntuple_keep(ABORT,err)

      implicit none
      save

      character*13 here
      parameter(here='sane_ntuple_keep')

      logical abort
      character*(*) err
      integer i,j,status(100,100),k,m

      include 'b_ntuple.cmn'
      include 'bigcal_data_structures.cmn'
      include 'bigcal_tof_parms.cmn'
      include 'hms_data_structures.cmn'
      include 'bigcal_gain_parms.cmn'
      include 'gen_event_info.cmn'
      include 'gen_data_structures.cmn'
      include 'gep_data_structures.cmn'
      include 'sane_ntuple.cmn'
      include 'sane_data_structures.cmn'
      include 'sem_data_structures.cmn'
      INCLUDE 'h_ntuple.cmn'
      include 'f1trigger_data_structures.cmn'
      include 'hms_calorimeter.cmn'
      include 'gen_detectorids.par'
      include 'gen_scalers.cmn'
      logical HEXIST ! CERNLIB function
      integer t_sane,l_sane,cer_sane
      integer icycle,inum,ihit
      real*8 Eb,theta_big, phi_big!,ccx,ccy,ccz
      real P_el(4),p_e,WW2
      common/FAKEBIG/Eb,theta_big, phi_big

c      logical middlebest

      real Mp
      parameter(Mp=.938272)


      err=' '
      ABORT=.false.

      if(sane_ntuple_max_segmentevents.gt.0) then
         if(sane_ntuple_segmentevents.gt.sane_ntuple_max_segmentevents) then
            call sane_ntup_change(ABORT,err)
            sane_ntuple_segmentevents=0
         else 
            sane_ntuple_segmentevents = sane_ntuple_segmentevents + 1
         endif
      endif

      if(.not.sane_ntuple_exists) return

      if(gbcm1_charge.ne.tcharge)then
         charge2s = gbcm1_charge-tcharge
         tcharge = gbcm1_charge
c         write(*,*)charge2s,tcharge,gbcm1_charge
      endif
      if(gscaler_change(538).ne.hel_p_scaler)then
        hel_p_scaler= gscaler_change(538)
        hel_p_trig= g_hel_pos
        dtime_p = gscaler_change(538)/float(g_hel_pos)
        g_hel_pos =0
c        write(*,*)'POS',hel_p_scaler,hel_p_trig,dtime_p
      endif
      if(gscaler_change(546).ne.hel_n_scaler)then
        hel_n_scaler= gscaler_change(546)
        hel_n_trig= g_hel_neg
        dtime_n = gscaler_change(546)/float(g_hel_neg)
        g_hel_neg =0
c        write(*,*)'NEG',hel_n_scaler,hel_n_trig,dtime_n
      endif
c      write(*,*)gbcm1_charge
      T_trgHMS     = gmisc_dec_data(11,1)
      call NANcheckF(T_trgHMS,3)
      T_trgBIG     = gmisc_dec_data(12,1) 
      call NANcheckF(T_trgBIG,3)
      T_trgPI0     = gmisc_dec_data(13,1)
      call NANcheckF(T_trgPI0,3)
      T_trgBETA    = gmisc_dec_data(14,1)
      call NANcheckF(T_trgBETA,3)
      T_trgCOIN1   = gmisc_dec_data(15,1)
      call NANcheckF(T_trgCOIN1,3)
      T_trgCOIN2   = gmisc_dec_data(16,1)
      call NANcheckF(T_trgCOIN2,3)

      luc_hit = 0
c      write(*,*) LUCITE_SANE_RAW_TOT_HITS2,LUCITE_SANE_RAW_TOT_HITS3
c      write(*,*)LUCITE_SANE_RAW_TDC_POS
      do i=1,LUCITE_SANE_RAW_TOT_HITS2
c         if(LUCITE_SANE_RAW_COUNTER_NUM2(i).eq.7)write(*,*)7
         if(LUCITE_SANE_RAW_TDC_POS(i).gt.0)then
            do j=1,LUCITE_SANE_RAW_TOT_HITS3
c         if(LUCITE_SANE_RAW_COUNTER_NUM3(j).eq.7)write(*,*)72
               if ( luc_hit .lt. 90) then
               if(LUCITE_SANE_RAW_TDC_NEG(j).gt.0.and.
     ,              LUCITE_SANE_RAW_COUNTER_NUM2(i).eq.LUCITE_SANE_RAW_COUNTER_NUM3(j))then
                  luc_hit            =  luc_hit+1
                  luc_row(luc_hit)   =  LUCITE_SANE_RAW_COUNTER_NUM2(i)
                  ladc_pos(luc_hit)  =  LUCITE_SANE_RAW_ADC_POS(luc_row(luc_hit)) - luc_ped_mean_pos(luc_row(luc_hit))
                  ladc_neg(luc_hit)  =  LUCITE_SANE_RAW_ADC_NEG(luc_row(luc_hit)) - luc_ped_mean_neg(luc_row(luc_hit))
                  luc_y(luc_hit)     =  -82.35 + (luc_row(luc_hit)-1)*6.1
                  call NANcheck(luc_hit,LUCITE_SANE_ID)
                  call NANcheck(luc_row(luc_hit),LUCITE_SANE_ID)
                  call NANcheck(ladc_neg(luc_hit),LUCITE_SANE_ID)
                  call NANcheck(ladc_pos(luc_hit),LUCITE_SANE_ID)
                  call NANcheck(ltdc_neg(luc_hit),LUCITE_SANE_ID)
                  call NANcheck(ltdc_pos(luc_hit),LUCITE_SANE_ID)
                  call CORRECT_RAW_TIME_SANE(LUCITE_SANE_RAW_TDC_POS(i),ltdc_pos(luc_hit))
                  call CORRECT_RAW_TIME_SANE(LUCITE_SANE_RAW_TDC_NEG(j),ltdc_NEG(luc_hit))
c                  call HFILL(10121, float(luc_row(luc_hit)), float(ltdc_pos(luc_hit)), 1.)
c                  call HFILL(10122, float(luc_row(luc_hit)), float(ltdc_neg(luc_hit)), 1.)
c                  call HFILL(10125, float(luc_row(luc_hit)), float(ladc_pos(luc_hit)), 1.)
c                  call HFILL(10126, float(luc_row(luc_hit)), float(ladc_neg(luc_hit)), 1.)
                  LUCITE_SANE_RAW_TDC_NEG(j) = 0
               endif
               endif
            enddo
            LUCITE_SANE_RAW_TDC_POS(i) = 0

         endif
      enddo
c      do i=1,LUCITE_SANE_RAW_TOT_HITS2
c         if(LUCITE_SANE_RAW_TDC_POS(i).gt.0)then
c                  luc_hit            =  luc_hit+1
c                  luc_row(luc_hit)   =  LUCITE_SANE_RAW_COUNTER_NUM2(i)
c                  ladc_pos(luc_hit)  =  LUCITE_SANE_RAW_ADC_POS(luc_row(luc_hit)) - luc_ped_mean_pos(luc_row(luc_hit))
c                  ladc_neg(luc_hit)  =  -100000
c                  call CORRECT_RAW_TIME_SANE(LUCITE_SANE_RAW_TDC_POS(i),ltdc_pos(luc_hit))
c                  ltdc_NEG(luc_hit)  =  -100000
c                  LUCITE_SANE_RAW_TDC_POS(i) = 0
c                  call HFILL(10121, float(luc_row(luc_hit)), float(ltdc_pos(luc_hit)), 1.)
c                  call HFILL(10125, float(luc_row(luc_hit)), float(ladc_pos(luc_hit)), 1.)
c            
c         endif
c      enddo
c      do i=1,LUCITE_SANE_RAW_TOT_HITS3
c         if(LUCITE_SANE_RAW_TDC_NEG(i).gt.0)then
c                  luc_hit            =  luc_hit+1
c                  luc_row(luc_hit)   =  LUCITE_SANE_RAW_COUNTER_NUM3(i)
c                  ladc_neg(luc_hit)  =  LUCITE_SANE_RAW_ADC_NEG(luc_row(luc_hit)) - luc_ped_mean_pos(luc_row(luc_hit))
c                  ladc_pos(luc_hit)  =  -100000
c                  call CORRECT_RAW_TIME_SANE(LUCITE_SANE_RAW_TDC_NEG(i),ltdc_neg(luc_hit))
c                  ltdc_POS(luc_hit)  =  -100000
c                  LUCITE_SANE_RAW_TDC_NEG(i) = 0
c                  call HFILL(10122, float(luc_row(luc_hit)), float(ltdc_neg(luc_hit)), 1.)
c                  call HFILL(10126, float(luc_row(luc_hit)), float(ladc_neg(luc_hit)), 1.)
c            
c         endif
c      enddo

      cer_hit = 0
c      write(*,*)'c, ',CERENKOV_SANE_RAW_COUNTER_NUM
c      write(*,*)'a, ' ,CERENKOV_SANE_RAW_ADC
      do i=1,CERENKOV_SANE_RAW_TOT_HITS2
         if(CERENKOV_SANE_RAW_TDC(i).gt.0)then
            cer_hit         =  cer_hit+1
            cer_num(cer_hit)   =  CERENKOV_SANE_RAW_COUNTER_NUM2(i)
            call CORRECT_RAW_TIME_SANE(CERENKOV_SANE_RAW_TDC(i),cer_tdc(cer_hit))
            cer_adcc(cer_hit) = CERENKOV_SANE_RAW_ADC(cer_num(cer_hit))-cer_sane_ped_mean(cer_num(cer_hit))
            call HFILL(10111,float(cer_num(cer_hit)),float(cer_TDC(cer_hit)), 1.)

            call NANcheck(cer_hit,CERENKOV_SANE_ID)
            call NANcheck(cer_num(cer_hit),CERENKOV_SANE_ID)
            call NANcheck(cer_adcc(cer_hit),CERENKOV_SANE_ID2)
            call NANcheck(cer_tdc(cer_hit),CERENKOV_SANE_ID)
c            if ( T_trgBIG.ge.40) then
c               call HFILL(10500+cer_num(cer_hit),float(cer_adcc(cer_hit)),float(cer_tdc(cer_hit)),1.)
c            endif
         endif
      enddo

       ceradc_hit = 0
      do i=1,CERENKOV_SANE_RAW_TOT_HITS
         if (ceradc_hit .le. 15) then
            ceradc_hit = ceradc_hit + 1
            ceradc_num(ceradc_hit)   =  CERENKOV_SANE_RAW_COUNTER_NUM(i)
            cer_adc(ceradc_hit)   =  CERENKOV_SANE_RAW_ADC(ceradc_num(ceradc_hit))-cer_sane_ped_mean(ceradc_num(ceradc_hit))
            call NANcheck(ceradc_hit,CERENKOV_SANE_ID2)
            call NANcheck(ceradc_num(ceradc_hit),CERENKOV_SANE_ID2)
            call NANcheck(cer_adc(ceradc_hit),CERENKOV_SANE_ID2)
            call HFILL(10112,float(ceradc_num(ceradc_hit)),float(cer_adc(ceradc_hit)), 1.)
         endif
       enddo
c
       
c

      x1t_hit         =  0
      if(x1t_hit.gt.300) go to 10
      do i=1,TRACKER_SANE_RAW_TOT_HITS_X
         if(TRACKER_SANE_RAW_TDC_X(i).gt.0)then
            x1t_hit         =  x1t_hit+1
            x1t_row(x1t_hit)   =  TRACKER_SANE_RAW_COUNTER_X(i)
            call CORRECT_RAW_TIME_SANE(TRACKER_SANE_RAW_TDC_X(i),x1t_tdc(x1t_hit))
            x1t_x(x1t_hit)     =  -12.32+0.37422*(x1t_row(x1t_hit)-1)

            call HFILL(10100,float(x1t_row(x1t_hit)),float(x1t_tdc(x1t_hit)),1.) 
            call NANcheck(x1t_hit,TRACKER_SANE_X_ID)
            call NANcheck(x1t_row(x1t_hit),TRACKER_SANE_X_ID)
            call NANcheck(x1t_tdc(x1t_hit),TRACKER_SANE_X_ID)
         endif
      enddo
      y1t_hit=0
      y2t_hit=0
c      write(*,*)gen_event_ID_number,TRACKER_SANE_RAW_TOT_HITS_Y
      
      do i=1,TRACKER_SANE_RAW_TOT_HITS_Y
c      write(*,*)'TDC, ', TRACKER_SANE_RAW_TDC_Y(i),TRACKER_SANE_RAW_COUNTER_Y(i)
         if(TRACKER_SANE_RAW_TDC_Y(i).lt.67000.and.
     ,        TRACKER_SANE_RAW_TDC_Y(i).gt.0)then
            if(TRACKER_SANE_RAW_COUNTER_Y(i).lt.129)then
               y1t_hit            =  y1t_hit + 1 
c               write(*,*)'Tracker TDC', y1t_hit,TRACKER_SANE_RAW_TDC_Y(i)
               if(y1t_hit.gt.300) go to 20
               y1t_row(y1t_hit)   =  TRACKER_SANE_RAW_COUNTER_Y(i)
               call CORRECT_RAW_TIME_SANE(TRACKER_SANE_RAW_TDC_Y(i),y1t_tdc(y1t_hit))
               y1t_y(y1t_hit)     =  -22.225+(y1t_row(y1t_hit)-1)*0.35
               call HFILL(10101,float(y1t_row(y1t_hit)),float(y1t_tdc(y1t_hit)),1.) 
               call NANcheck(y1t_hit,TRACKER_SANE_Y_ID)
               call NANcheck(y1t_row(y1t_hit),TRACKER_SANE_Y_ID)
               call NANcheck(y1t_tdc(y1t_hit),TRACKER_SANE_Y_ID)

             else if(TRACKER_SANE_RAW_COUNTER_Y(i).lt.257)then
               y2t_hit            =  y2t_hit + 1 
               if(y2t_hit.gt.300) go to 20
               y2t_row(y2t_hit)   =  TRACKER_SANE_RAW_COUNTER_Y(i)-128
               call CORRECT_RAW_TIME_SANE(TRACKER_SANE_RAW_TDC_Y(i),y2t_tdc(y2t_hit))
               y2t_y(y2t_hit)     =  -22.4+(y2t_row(y2t_hit)-1)*0.35
               call HFILL(10102,float(y2t_row(y2t_hit)),float(y2t_tdc(y2t_hit)),1.) 
               call NANcheck(y2t_hit,TRACKER_SANE_Y_ID)
               call NANcheck(y2t_row(y2t_hit),TRACKER_SANE_Y_ID)
               call NANcheck(y2t_tdc(y2t_hit),TRACKER_SANE_Y_ID)
            endif
         endif
 20      CONTINUE
      enddo
c          do inum=1,nclust
c         enddo
             hms_p = 0
      if(HSNUM_FPTRACK.gt.0)then
c         write(*,*)HSNUM_FPTRACK,hsp,hstheta
         hms_p        = hsp	
         call NANcheckF(hms_p,4)
         hms_e        = hsenergy
         call NANcheckF(hms_e,4)
         hms_theta    = hstheta
         call NANcheckF(hms_theta,4)
         hms_phi      = hsphi
         call NANcheckF(hms_phi,4)
         hsxfp_s      = hsx_fp
         call NANcheckF(hsxfp_s,4)
         hsyfp_s      = hsy_fp
         call NANcheckF(hsyfp_s,4)
         hsxpfp_s     = hsxp_fp
         call NANcheckF(hsxpfp_s,4)
         hsypfp_s     = hsyp_fp
         call NANcheckF(hsypfp_s,4)
         hms_xtar     = hsx_tar*100
         call NANcheckF(hms_xtar,4)
         hms_ytar     = hsy_tar*100
         call NANcheckF(hms_ytar,4)
c         write(*,*)hms_ytar,hsy_tar
         hms_yptar    = hsyp_tar
         call NANcheckF(hms_yptar,4)
         hms_xptar    = hsxp_tar
c         write(*,*)hms_yptar,hms_xptar
         call NANcheckF(hms_xptar,4)
         hms_delta    = hsdelta
         call NANcheckF(hms_delta,4)
         hms_start    = hstart_time
         call NANcheck(hms_start,4)
         hsshtrk_s    = HSTRACK_ET
         call NANcheckF(hsshtrk_s,4)
         hsshsum_s    = hsshsum
         call NANcheckF(hsshsum_s,4)
         hsbeta_s     = hsbeta 
         call NANcheckF(hsbeta_s,4)
         hms_cer_npe1 = hcer_npe(1)
         call NANcheckF(hms_cer_npe1,4)
         hms_cer_npe2 = hcer_npe(2)
         call NANcheckF(hms_cer_npe2,4)
         hms_cer_adc1 = hcer_adc(1) 
         call NANcheckF(hms_cer_adc1,4)
         hms_cer_adc2 = hcer_adc(2)
         call NANcheckF(hms_cer_adc2,4)
         call HFILL(10302,X_HMS,Y_HMS,1.)
c         if(nclust.eq.1)then
         do i=1,nclust
            call HFILL(10300,X_HMS,xclust(i)+Bigcal_SHIFT(1),1.) 
            
            call HFILL(10304,X_HMS-Xclust(i),Y_HMS-Yclust(i),1.)
            call HFILL(10301,Y_HMS,Yclust(i)+Bigcal_SHIFT(2),1.) 
c            write(*,*)Bigcal_SHIFT(1),Bigcal_SHIFT(2)
               if(abs(X_HMS-xclust(i)-Bigcal_SHIFT(1)).lt.10.and.
     ,              abs(Y_HMS-Yclust(i)-Bigcal_SHIFT(2)).lt.10)then
c                  write(*,*)'Slow raster ',gsrx_calib,gsry_calib
c                  write(*,*)'HMS raster ',hms_xtar,hms_ytar
                  call HFILL(10303,Xclust(i)+Bigcal_SHIFT(1),Yclust(i)+Bigcal_SHIFT(2),1.)
                  call HFILL(10310,hms_delta,hms_yptar ,1.)
                  call HFILL(10311,hms_delta,hms_xptar ,1.)
                  call HFILL(10312,dpel_hms,hms_yptar ,1.)
                  call HFILL(10313,dpel_hms,hms_xptar ,1.)
                  call HFILL(10315,dpel_hms,hms_ytar ,1.)
                  call HFILL(10314,dpel_hms,hms_xtar ,1.)
                  call HF1(10321,0.006*hms_delta+0.01-hms_yptar,1.)
                  P_e = hms_p
                  P_el(1) = p_e*sin(hms_theta)*cos(HMS_phi)
                  P_el(2) = p_e*sin(hms_theta)*sin(HMS_phi)
                  P_el(3) = p_e*cos(hms_theta)
                  P_el(4) = hms_e
                  ww2 = (GEBEAM+Mp-P_el(4))**2-
     ,                 (P_el(1)**2+p_el(2)**2+(GEBEAM-p_el(3))**2)
c                  write(*,*)ww2
                  call HF1(10322,ww2,1.)
                  call HFILL(10323,ww2,hms_yptar,1.)
                  call HFILL(10324,ww2,hms_xtar,1.)
                
               endif
         enddo
c         endif

      endif
      rast_x       = gfry_raw_adc
      call NANcheckF(rast_x,3)
      rast_y       = gfrx_raw_adc
      call NANcheckF(rast_y,3)
      i_helicity   = gbeam_helicity
      call NANcheck(i_helicity,3)
      slow_rast_x  = gsrx_calib
      call NANcheckF(gsrx_raw_adc,3)
      slow_rast_y  = gsry_calib
      call HFILL(10215,gsry_raw_adc,gsrx_raw_adc, 1.)

      call HFILL(10216,gsrx_calib,gsry_calib, 1.)

      if(HSNUM_FPTRACK.gt.0)then
            
                  call HFILL(10316,slow_rast_y,-hms_xtar ,1.)
                  call HFILL(10317,slow_rast_x,hms_ytar ,1.)
      endif
      call NANcheckF(gsry_raw_adc,3)
      sem_x        = -ntbpmx/10.
      call NANcheckF(sem_x,3)
      sem_y        = ntbpmy/10.
      call NANcheckF(sem_y,3)
      call HFILL(10214,sem_x,sem_y, 1.)
c      write(*,*)'2 ',sem_x,sem_y

       do i =1,  nclust
c         write(*,*)eclust(i)
c         if(HSNUM_FPTRACK.gt.0)then

          n_clust = nclust
          call Bigcal_Betta(i)
          call icer(i)
          call tracker(i)
          call TrackerCoordnate(i)
          call GeometryMatch(i)
          call Lucite(i)
c            if(abs(X_HMS-Xclust(i)-Bigcal_SHIFT(1)).lt.10.and.
c     ,           abs(Y_HMS-Yclust(i)-Bigcal_SHIFT(2)).lt.10)then
c                  WRITE(*,*)'call 2',NCLUST
c               call Bigcal_Betta(i)
c            endif
c         endif
         do j=1, ncellclust(i)
            call HFILL(10200,float(ixcell(j,i)),float(iycell(j,i)), 1.)
         enddo
         if(sane_ntuple_type.eq.1)then
            n_clust = nclust
c            call Lucite(i)
         endif
      enddo
      abort=.not.HEXIST(sane_ntuple_ID)
      if(abort) then
         call G_build_note(':Ntuple ID#$ does not exist',
     $        '$',sane_ntuple_ID,' ',0.,' ',err)
         call G_add_path(here,err)
      else 
         icycle=999999
         call HFNT(sane_ntuple_ID)
         
      endif
 10   CONTINUE
      return 
      end

      SUBROUTINE CORRECT_RAW_TIME_SANE(RAW_TDC,CORRECTED_TDC)
      IMPLICIT NONE
      include 'sane_data_structures.cmn'
      include 'f1trigger_data_structures.cmn'
c
c     Function arguments are RAW_TDC -raw TDC value
c     and CORRECTED_TDC -Corrected by Trigger time and rolover time 
c     MAKE SURE TO Include correct parameter files
c
c
      integer*4 RAW_TDC, CORRECTED_TDC, f1trigmax
      save

c find largest value of trigger time, to check rollover
      if(TRIGGER_F1_START_TDC_COUNTER(
     >        SANE_TRIGGER_COUNTER) .gt.f1trigmax) then
        write(6,'('' SANE trigger time max='',i8)')
     >  TRIGGER_F1_START_TDC_COUNTER(
     >        SANE_TRIGGER_COUNTER)
        f1trigmax = 
     >  TRIGGER_F1_START_TDC_COUNTER(
     >        SANE_TRIGGER_COUNTER)
      endif
      if(RAW_TDC.gt.0)then
         CORRECTED_TDC =  RAW_TDC - 
     ,        TRIGGER_F1_START_TDC_COUNTER(SANE_TRIGGER_COUNTER)
c
c     Taking care of ROLOVER For positive TDC
c     
         if(CORRECTED_TDC.lt.-30000)
     ,        CORRECTED_TDC = CORRECTED_TDC+TRIGGER_F1_ROLOVER(SANE_TRIGGER_COUNTER)
         if(CORRECTED_TDC.gt.30000)
     ,        CORRECTED_TDC = CORRECTED_TDC-TRIGGER_F1_ROLOVER(SANE_TRIGGER_COUNTER)
      else
         CORRECTED_TDC =0
      endif 

      end

      subroutine NANcheck(l,did)
      IMPLICIT NONE
      integer*4 l
      integer did
      if(l.ne.l)then
         l=0
c         write(*,*)did
      endif
      end
      subroutine NANcheckF(l,did)
      IMPLICIT NONE
      real*4 l
      integer did
      if(l.ne.l)then
         l=0
c         write(*,*)did
      endif
      end
