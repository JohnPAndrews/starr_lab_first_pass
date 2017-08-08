function demoVerticalLine
  % Create the variable which is required to know if the line move is active or not.
  mouseDown = false;
  % Create the first value for the xlimMode (used in callbacks)
  xLimMode = 'auto';
  % create a dialog, with the mouse actions set
  hFig = dialog ( 'windowstyle', 'normal', 'WindowButtonMotionFcn', @MouseMove, 'WindowButtonUpFcn', @MouseUp );
  % create an axes
  ax = axes ( 'parent', hFig, 'position', [0.1 0.2 0.8 0.7], 'nextplot', 'add' );
  % create a popup menu
  pop = uicontrol ( 'parent', hFig, 'style', 'popupmenu', 'string', { 'sin', 'cos' }, 'Callback', @UpdatePlot );  
  % some dummy data
  x = -pi:0.01:pi;
  % an initial X for my example
  vLineX = randi(length(x));
  % On first time through create a plot
  userPlot = []; % init a value -> this is used to clear the previous user data
  UpdatePlot();
  % get the y limits of the data to be plotted
  ylim = get ( ax, 'ylim' );
  % plot the vertical line
  hLine = plot ( ax, [x(vLineX) x(vLineX)], ylim, 'ButtonDownFcn', @MouseDown );
  % a callback for plotting the user data
  function UpdatePlot ( obj, event )
    % delete any user data which is already plotted
    delete ( userPlot );
    % plot the user data
    switch get ( pop, 'value' )
      case 1 % sin
        userPlot = plot ( ax, x, sin(x), 'r.-' );
      case 2 % cos
        userPlot = plot ( ax, x, cos(x), 'b.-' );
    end
  end
  % a function which is called whenever the mouse is moved
  function MouseMove ( obj, event )
    % only run this section if the user has clicked on the line
    if mouseDown
      % get the current point on the axes
      cp = get ( ax, 'CurrentPoint' );
      % update the xdata of the line handle.
      set ( hLine, 'XData', [cp(1,1) cp(1,1)] );
    end
  end
  % callback from the user clicking on the line
  function MouseDown ( obj, event )
    % get the current xlimmode
    xLimMode = get ( ax, 'xlimMode' );
    % setting this makes the xlimits stay the same (comment out and test)
    set ( ax, 'xlimMode', 'manual' );
    % set the mouse down flag
    mouseDown = true;
  end
  % on mouse up 
  function MouseUp ( obj, event )
    % reset the xlim mode once the moving stops
    set ( ax, 'xlimMode', xLimMode );
    % reset the mouse down flag.
    mouseDown = false;
  end
end