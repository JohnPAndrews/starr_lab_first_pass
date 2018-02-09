classdef TimeDomainData
   properties
      Data
      Fs
      Idx 
      FreqBands
      FreqNames
      AvgBands
      MaxBands 
      AvgBandsNorm
      MaxBandsNorm
      freqs
      psd 
   end
   % The internal data implementation is not publicly exposed
    properties (Access = 'protected')
        props = containers.Map;
    end
   methods
      function obj = TimeDomainData(dat,Fs,idx)
         if nargin == 1
             error('missing data or sampling rate')
         elseif nargin == 2 
            if isnumeric(dat) && isnumeric(Fs)
               obj.Data = dat;
               obj.Fs   = Fs; 
            else
               error('Value must be numeric')
            end 
         elseif nargin == 3 
             if length(idx) ~=2 
                 error('idx can only be of length 2'); 
             else
                 obj.Data = dat(idx(1):idx(2));
                 obj.Fs   = Fs;
             end 
         elseif nargin > 3 
             error('Too many arguments, class requires data and sampling rate and idx at most')
         end
         
         [psd,freqs] = pwelch(obj.Data,Fs,Fs/2,1:Fs/2,Fs,'psd');
         psd = log10(psd);
         obj.psd = psd; obj.freqs = freqs; 
         FreqBands = [1 4; 4 8; 8 13; 13 30; 13 20; 20 30; 30 50; 50 90];
         FreqNames = {'Delta', 'Theta', 'Alpha','Beta','LowBeta','HighBeta','LowGamma','HighGamma'}';
         obj.FreqBands = FreqBands;
         obj.FreqNames = FreqNames;
         for f = 1:size(FreqBands,1)
             idx = freqs >= FreqBands(f,1) &  freqs <= FreqBands(f,2) ;
             obj.AvgBands(f) = mean( psd(idx));
             obj.MaxBands(f)    = max( psd(idx));
         end
         %power normalize
         idx  = freqs >= 5 &  freqs <= 45;
         power5_45 = sum(abs(psd(idx)));
         idx  = freqs >= 55 &  freqs <= 95;
         power55_95 = sum(abs(psd(idx)));
         for f = 1:size(FreqBands,1)
             idx = freqs >= FreqBands(f,1) &  freqs <= FreqBands(f,2) ;
             if f == 7; divBy = power55_95; else; divBy = power5_45;end ;
             obj.AvgBandsNorm(f) = sum( abs(psd(idx))) / divBy;
             obj.MaxBandsNorm(f) = max( abs(psd(idx))) / divBy;
         end
      end
      % Overload property names retrieval
      function names = properties(obj)
          names = fieldnames(obj);
      end
      % Overload class object display
      function disp(obj)
          disp([obj.props.keys', obj.props.values']);  % display as a cell-array
      end
      function s = getTable(obj)
          for f = 1:size(obj.FreqBands,1)
              fn = sprintf('avg%s',obj.FreqNames{f});
              s.(fn) = obj.AvgBands(f); 
              fn = sprintf('max%s',obj.FreqNames{f});
              s.(fn) = obj.MaxBands(f);
              fn = sprintf('avgnorm%s',obj.FreqNames{f});
              s.(fn) = obj.AvgBandsNorm(f); 
              fn = sprintf('maxnorm%s',obj.FreqNames{f});
              s.(fn) = obj.MaxBandsNorm(f);
          end

      end
      function hfig = plotData(obj)
          hfig = figure();
          % plot raw data 
          subplot(3,2,1); 
          plot((1:length(obj.Data))./obj.Fs,obj.Data);
          xlabel('Time (seconds)'); 
          ylabel('Voltage'); 
          title('Raw Data'); 
          % plot psd 
          hax = subplot(3,2,2);
          hold on;
          handles.freqranges = [1 4; 4 8; 8 13; 13 20; 20 30; 30 50; 50 90];
          handles.freqnames  = {'Delta', 'Theta', 'Alpha','LowBeta','HighBeta','LowGamma','HighGamma'}';
          cuse = parula(size(handles.freqranges,1));
          ydat = [10 10 -10 -10];
          handles.axesclr = hax;
          for p = 1:size(handles.freqranges,1)
              freq = handles.freqranges(p,:);
              xdat = [freq(1) freq(2) freq(2) freq(1)];
              handles.hPatches(p) = patch('XData',xdat,'YData',ydat,'YLimInclude','off');
              handles.hPatches(p).Parent = hax;
              handles.hPatches(p).FaceColor = cuse(p,:);
              handles.hPatches(p).FaceAlpha = 0.3;
              handles.hPatches(p).EdgeColor = 'none';
              handles.hPatches(p).Visible = 'on';
          end

          hp = plot(obj.freqs,obj.psd);
          hp.LineWidth = 2; 
          xlabel('Frequency (Hz)'); 
          ylabel('Power  (log_1_0\muV^2/Hz)'); 
          title('Freq Domain data'); 
          xlim([1 100]); 

          % plot bar graph avg 
          hax = subplot(3,2,3);
          hb = bar(obj.AvgBands);
          set(hax,'xticklabel',obj.FreqNames)
          set(hax,'XTickLabelRotation',45)
          ylabel('Power  (log_1_0\muV^2/Hz)');
          title('Average Freq');

          % plot bar graph max 
          hax = subplot(3,2,4);
          hb = bar(obj.MaxBands);
          set(hax,'xticklabel',obj.FreqNames)
          set(hax,'XTickLabelRotation',45)
          ylabel('Power  (log_1_0\muV^2/Hz)');
          title('Max Freq');
          % plot bar graph avg 
           hax = subplot(3,2,5);
          hb = bar(obj.AvgBandsNorm);
          set(hax,'xticklabel',obj.FreqNames)
          set(hax,'XTickLabelRotation',45)
          ylabel('Power  (log_1_0\muV^2/Hz)');
          title('Avg Bands Norm');
          % plot bar graph max 
          
           hax = subplot(3,2,6);
          hb = bar(obj.MaxBandsNorm);
          set(hax,'xticklabel',obj.FreqNames)
          set(hax,'XTickLabelRotation',45)
          ylabel('Power  (log_1_0\muV^2/Hz)');
          title('Max Bands Norm');    
      end
      function hfig = plotSpectrogram(obj)
          datdc = obj.dat - mean(obj.dat); 
      end
   end
end