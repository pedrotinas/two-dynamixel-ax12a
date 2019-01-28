function varargout = main(varargin)


% Edit the above text to modify the response to help untitled3e

% Last Modified by GUIDE v2.5 28-Jan-2019

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled3e_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled3e_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before untitled3e is made visible.
function untitled3e_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled3e (see VARARGIN)

% Choose default command line output for untitled3e
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled3e wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled3e_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%-------------------------------

handles.lib_name = '';
addpath('dynamixel_sdk');
addpath('m_basic_function\group_bulk_read')
addpath('m_basic_function\group_bulk_write')
addpath('m_basic_function\group_sync_read')
addpath('m_basic_function\group_sync_write')
addpath('m_basic_function\packet_handler')
addpath('m_basic_function\port_handler')

if strcmp(computer, 'PCWIN')
  handles.lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  handles.lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  handles.lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  handles.lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  handles.lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(handles.lib_name)
    [notfound, warnings] = loadlibrary(handles.lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
end
% Protocol version
handles.PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

% Default setting
handles.DXL_ID                      = 1;            % Dynamixel ID: 1
handles.DXL_ID2                     = 2;            % Dynamixel ID: 2

handles.BAUDRATE                    = 1000000;

handles.DEVICENAME                  = 'COM4';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'
handles.ADDR_MX_TORQUE_ENABLE       = 24;           % Control table address is different in Dynamixel model
handles.COMM_SUCCESS                = 0;            % Communication Success result value
handles.COMM_TX_FAIL                = -1001;        % Communication Tx Failed
handles.dxl_comm_result = handles.COMM_TX_FAIL;             % Communication result
handles.dxl_error = 0;                              % Dynamixel error
handles.TORQUE_ENABLE               = 1;            % Value for enabling the torque







% Initialize PortHandler Structs
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
handles.port_num = portHandler(handles.DEVICENAME);

% Initialize PacketHandler Structs
packetHandler();


% Open port
if (openPort(handles.port_num))
    pause (1);
   set(handles.btn_color,'BackgroundColor','green');
else
    %unloadlibrary(handles.lib_name);
    set(handles.btn_color, 'BackgroundColor', 'Red');
    %fprintf('Failed to open the port!\n');
    %input('Press any key to terminate...\n');
    %return;
    pause(0.5);
    %close()
end


% Set port baudrate
if (setBaudRate(handles.port_num, handles.BAUDRATE))
    pause(1);
    set(handles.btn_color2, 'backgroundcolor', 'green');
    %fprintf('Succeeded to change the baudrate!\n');
else
    unloadlibrary(handles.lib_name);
    set(handles.btn_color2, 'backgroundcolor', 'red') ;
     pause(2);
     %warning ( 'Please verify if all components are correctly connected or try turn off and turn on USB');
    close()
    %fprintf('Failed to change the baudrate!\n');
    %input('Press any key to terminate...\n');
    %return;
end


% Enable Dynamixel Torque 1
write1ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_TORQUE_ENABLE, handles.TORQUE_ENABLE);
handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
if handles.dxl_comm_result ~= handles.COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
elseif handles.dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles. dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

% Enable Dynamixel Torque 2
write1ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_TORQUE_ENABLE, handles.TORQUE_ENABLE);
handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
if handles.dxl_comm_result ~= handles.COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
elseif handles.dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles. dxl_error));
else
    fprintf('Dynamixel has been successfully connected \n');
end

% Enable Buttons

set(handles.ex1, 'enable', 'on')
set(handles.ex2, 'enable', 'on')
set(handles.ex3, 'enable', 'on')
set(handles.motor_off, 'enable', 'on')
set(handles.pushbutton1, 'enable', 'off')



% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in ex1.
function ex1_Callback(hObject, eventdata, handles)
% hObject    handle to ex1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%-----------------------




% Control table address 1

handles.ADDR_MX_GOAL_POSITION       = 30;
handles.ADDR_MX_PRESENT_POSITION    = 36;
handles.ADDR_MX_MOVING_SPEED        = 32;
handles.ADDR_MX_TORQUE_LIMIT        = 34;
handles.ADDR_MX_PRESENT_SPEED       = 38;

% Control table address 2

handles.ADDR_MX_GOAL_POSITION2       = 30;
handles.ADDR_MX_PRESENT_POSITION2    = 36;
handles.ADDR_MX_MOVING_SPEED2        = 32;
handles.ADDR_MX_TORQUE_LIMIT2        = 34;
handles.ADDR_MX_PRESENT_SPEED2       = 38;



% Protocol version
handles.PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

% Default setting
handles.DXL_ID                      = 1;            % Dynamixel ID: 1
handles.DXL_ID2                     = 2;            % Dynamixel ID: 2
handles.BAUDRATE                    = 1000000;
handles.DEVICENAME                  = 'COM4';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

                                            
% Values of Dynamixel 1
handles.TORQUE_ENABLE               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE  = 387 ;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE  = 520;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD = 10; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED            = 300;
handles.DXL_TORQUE_LIMIT            = 523;
handles.DXL_MIN_SPEED               = 0;

% Values of Dynamixel 2
handles.TORQUE_ENABLE2               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE2              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE2  = 308 ;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE2  = 175;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD2 = 10; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED2            = 300;
handles.DXL_TORQUE_LIMIT2            = 523;
handles.DXL_MIN_SPEED2               = 0;

handles.ESC_CHARACTER               = 'e';          % Key for escaping loop

handles.COMM_SUCCESS                = 0;            % Communication Success result value
handles.COMM_TX_FAIL                = -1001;        % Communication Tx Failed


handles.index = 1;
handles.dxl_comm_result = handles.COMM_TX_FAIL;             % Communication result
handles.dxl_goal_position = [handles.DXL_MINIMUM_POSITION_VALUE handles.DXL_MAXIMUM_POSITION_VALUE];         % Goal position
handles.dxl_present_speed = [0 2047];

%Values Dynamixel 2
handles.dxl_goal_position2 = [handles.DXL_MINIMUM_POSITION_VALUE2 handles.DXL_MAXIMUM_POSITION_VALUE2];         % Goal position


%Values Dynamixel 1
handles.dxl_error = 0;                              % Dynamixel error
handles.dxl_present_position = 0;                   % Present position
handles.dxl_Present_speed = 1;                      % Present Speed

%Values Dynamixel 2
handles.dxl_error2 = 0;                              % Dynamixel error
handles.dxl_present_position2 = 0;                   % Present position
handles.dxl_Present_speed2 = 1;                      % Present Speed


handles.aux = 0;


% Moving Speed Dynamixel 1

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_MOVING_SPEED, handles.DXL_MOVING_SPEED);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Moving Speed Dynamixel 2

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_MOVING_SPEED2, handles.DXL_MOVING_SPEED2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


% Torque Limit Dynamixel 1

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_TORQUE_LIMIT, handles.DXL_TORQUE_LIMIT);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Torque Limit Dinamixel 2

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_TORQUE_LIMIT2, handles.DXL_TORQUE_LIMIT2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


while 1
   
    if handles.aux == 2
       break;
    end

    % Write goal position Dynamixel 1
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_GOAL_POSITION, handles.dxl_goal_position(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
    
    
    % Write goal position Dynamixel 2
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_GOAL_POSITION2, handles.dxl_goal_position2(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
    
    
    while 1
        % Read present position Dynamixel 1
        handles.dxl_present_position = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_PRESENT_POSITION);
        handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID, handles.dxl_goal_position(handles.index), handles.dxl_present_position);

         % Read present position Dynamixel 2
        handles.dxl_present_position2 = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_PRESENT_POSITION2);
        handles.dxl_comm_result2 = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error2 = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID2, handles.dxl_goal_position2(handles.index), handles.dxl_present_position2);
        
        
        if ~(abs(handles.dxl_goal_position(handles.index) - handles.dxl_present_position) > handles.DXL_MOVING_STATUS_THRESHOLD)
            pause(6.0);
            
            break;
        end
       
       
        
     end
 
     handles.aux = handles.aux + 1;
        
        
    % Change goal position
    if handles.index == 1
        handles.index = 2;
    else
       handles.index = 1;
    end
end












% --- Executes on button press in ex2.
function ex2_Callback(hObject, eventdata, handles)
% hObject    handle to ex2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%-----------------------




% Control table address

handles.ADDR_MX_GOAL_POSITION       = 30;
handles.ADDR_MX_PRESENT_POSITION    = 36;
handles.ADDR_MX_MOVING_SPEED        = 32;
handles.ADDR_MX_TORQUE_LIMIT        = 34;
handles.ADDR_MX_PRESENT_SPEED       = 38;

% Control table address 2

handles.ADDR_MX_GOAL_POSITION2       = 30;
handles.ADDR_MX_PRESENT_POSITION2    = 36;
handles.ADDR_MX_MOVING_SPEED2        = 32;
handles.ADDR_MX_TORQUE_LIMIT2        = 34;
handles.ADDR_MX_PRESENT_SPEED2       = 38;

% Protocol version
handles.PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

% Default setting
handles.DXL_ID                      = 1;            % Dynamixel ID: 1
handles.BAUDRATE                    = 1000000;
handles.DEVICENAME                  = 'COM4';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

handles.TORQUE_ENABLE               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE  = 723;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE  = 660;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD = 5; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED            = 250;
handles.DXL_TORQUE_LIMIT            = 523;
handles.DXL_MIN_SPEED               = 0;

% Values of Dynamixel 2
handles.TORQUE_ENABLE2               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE2              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE2  = 300;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE2  = 363;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD2 = 5; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED2            = 250;
handles.DXL_TORQUE_LIMIT2            = 523;
handles.DXL_MIN_SPEED2               = 0;



handles.ESC_CHARACTER               = 'e';          % Key for escaping loop

handles.COMM_SUCCESS                = 0;            % Communication Success result value
handles.COMM_TX_FAIL                = -1001;        % Communication Tx Failed


handles.index = 1;
handles.dxl_comm_result = handles.COMM_TX_FAIL;             % Communication result
handles.dxl_goal_position = [handles.DXL_MINIMUM_POSITION_VALUE handles.DXL_MAXIMUM_POSITION_VALUE];         % Goal position
handles.dxl_present_speed = [0 2047];

%Values Dynamixel 2
handles.dxl_goal_position2 = [handles.DXL_MINIMUM_POSITION_VALUE2 handles.DXL_MAXIMUM_POSITION_VALUE2];         % Goal position


handles.dxl_error = 0;                              % Dynamixel error
handles.dxl_present_position = 0;                   % Present position
handles.dxl_Present_speed = 1;                      % Present Speed

%Values Dynamixel 2
handles.dxl_error2 = 0;                              % Dynamixel error
handles.dxl_present_position2 = 0;                   % Present position
handles.dxl_Present_speed2 = 1;                      % Present Speed


handles.aux = 0;


% Moving Speed Dynamixel 1

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_MOVING_SPEED, handles.DXL_MOVING_SPEED);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Moving Speed Dynamixel 2

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_MOVING_SPEED2, handles.DXL_MOVING_SPEED2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


% Torque Limit Dynamixel 1

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_TORQUE_LIMIT, handles.DXL_TORQUE_LIMIT);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Torque Limit Dinamixel 2

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_TORQUE_LIMIT2, handles.DXL_TORQUE_LIMIT2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


while 1
   
    if handles.aux == 2
       break;
    end

    % Write goal position Dynamixel 1
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_GOAL_POSITION, handles.dxl_goal_position(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
   
    
    % Write goal position Dynamixel 2
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_GOAL_POSITION2, handles.dxl_goal_position2(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
    
    
    while 1
        % Read present position Dynamixel 1
        handles.dxl_present_position = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_PRESENT_POSITION);
        handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID, handles.dxl_goal_position(handles.index), handles.dxl_present_position);

         % Read present position Dynamixel 2
        handles.dxl_present_position2 = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_PRESENT_POSITION2);
        handles.dxl_comm_result2 = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error2 = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID2, handles.dxl_goal_position2(handles.index), handles.dxl_present_position2);
        
        
        if ~(abs(handles.dxl_goal_position(handles.index) - handles.dxl_present_position) > handles.DXL_MOVING_STATUS_THRESHOLD)
            pause(5.0);
            
            break;
        end
       
       
        
     end
 
     handles.aux = handles.aux + 1;
        
        
    % Change goal position
    if handles.index == 1
        handles.index = 2;
    else
       handles.index = 1;
    end
end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ex3.
function ex3_Callback(hObject, eventdata, handles)
% hObject    handle to ex3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%-----------------------




% Control table address

handles.ADDR_MX_GOAL_POSITION       = 30;
handles.ADDR_MX_PRESENT_POSITION    = 36;
handles.ADDR_MX_MOVING_SPEED        = 32;
handles.ADDR_MX_TORQUE_LIMIT        = 34;
handles.ADDR_MX_PRESENT_SPEED       = 38;


% Control table address 2

handles.ADDR_MX_GOAL_POSITION2       = 30;
handles.ADDR_MX_PRESENT_POSITION2    = 36;
handles.ADDR_MX_MOVING_SPEED2        = 32;
handles.ADDR_MX_TORQUE_LIMIT2        = 34;
handles.ADDR_MX_PRESENT_SPEED2       = 38;


% Protocol version
handles.PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

% Default setting
handles.DXL_ID                      = 1;            % Dynamixel ID: 1
handles.BAUDRATE                    = 1000000;
handles.DEVICENAME                  = 'COM4';       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

handles.TORQUE_ENABLE               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE  = 830;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE  = 678;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD = 5; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED            = 1000;
handles.DXL_TORQUE_LIMIT            = 700;
handles.DXL_MIN_SPEED               = 0;

% Values of Dynamixel 2
handles.TORQUE_ENABLE2               = 1;            % Value for enabling the torque
handles.TORQUE_DISABLE2              = 0;            % Value for disabling the torque
handles.DXL_MINIMUM_POSITION_VALUE2  = 201;          % Dynamixel will rotate between this value
handles.DXL_MAXIMUM_POSITION_VALUE2  = 353;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
handles.DXL_MOVING_STATUS_THRESHOLD2 = 5; % Dynamixel moving status threshold
handles.DXL_MOVING_SPEED2            = 1000;
handles.DXL_TORQUE_LIMIT2            = 700;
handles.DXL_MIN_SPEED2               = 0;


handles.ESC_CHARACTER               = 'e';          % Key for escaping loop

handles.COMM_SUCCESS                = 0;            % Communication Success result value
handles.COMM_TX_FAIL                = -1001;        % Communication Tx Failed


handles.index = 1;
handles.dxl_comm_result = handles.COMM_TX_FAIL;             % Communication result
handles.dxl_goal_position = [handles.DXL_MINIMUM_POSITION_VALUE handles.DXL_MAXIMUM_POSITION_VALUE];         % Goal position
handles.dxl_present_speed = [0 2047];

%Values Dynamixel 2
handles.dxl_goal_position2 = [handles.DXL_MINIMUM_POSITION_VALUE2 handles.DXL_MAXIMUM_POSITION_VALUE2];         % Goal position


handles.dxl_error = 0;                              % Dynamixel error
handles.dxl_present_position = 0;                   % Present position
handles.dxl_Present_speed = 1;                      % Present Speed

handles.aux = 0;


% Moving Speed Dynamixel 1

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_MOVING_SPEED, handles.DXL_MOVING_SPEED);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Moving Speed Dynamixel 2

 write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_MOVING_SPEED2, handles.DXL_MOVING_SPEED2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
   handles. dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles. dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


% Torque Limit Dynamixel 1

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_TORQUE_LIMIT, handles.DXL_TORQUE_LIMIT);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end

% Torque Limit Dinamixel 2

write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_TORQUE_LIMIT2, handles.DXL_TORQUE_LIMIT2);
   handles. dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end


while 1
   
    if handles.aux == 2
       break;
    end

    % Write goal position Dynamixel 1
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_GOAL_POSITION, handles.dxl_goal_position(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
    
    
    % Write goal position Dynamixel 2
    write2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_GOAL_POSITION2, handles.dxl_goal_position2(handles.index));
    handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
    handles.dxl_error = getLastRxPacketError(handles.port_num, handles. PROTOCOL_VERSION);
    if handles.dxl_comm_result ~= handles.COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
    elseif handles.dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
    end
    
    
    while 1
        % Read present position Dynamixel 1
        handles.dxl_present_position = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID, handles.ADDR_MX_PRESENT_POSITION);
        handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID, handles.dxl_goal_position(handles.index), handles.dxl_present_position);

         % Read present position Dynamixel 2
        handles.dxl_present_position2 = read2ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION, handles.DXL_ID2, handles.ADDR_MX_PRESENT_POSITION2);
        handles.dxl_comm_result2 = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
        handles.dxl_error2 = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
        if handles.dxl_comm_result ~= handles.COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
        elseif handles.dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
        end

        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', handles.DXL_ID2, handles.dxl_goal_position2(handles.index), handles.dxl_present_position2);
        
        
        if ~(abs(handles.dxl_goal_position(handles.index) - handles.dxl_present_position) > handles.DXL_MOVING_STATUS_THRESHOLD)
            pause(2.0);
            
            break;
        end
       
       
        
     end
 
     handles.aux = handles.aux + 1;
        
        
    % Change goal position
    if handles.index == 1
        handles.index = 2;
    else
       handles.index = 1;
    end

end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in motor_off.
function motor_off_Callback(hObject, eventdata, handles)
% hObject    handle to motor_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
guidata(hObject, handles);


handles.TORQUE_DISABLE              = 0;            % Value for disabling the torque

% Disable Dynamixel Torque
write1ByteTxRx(handles.port_num, handles.PROTOCOL_VERSION,handles. DXL_ID, handles.ADDR_MX_TORQUE_ENABLE, handles.TORQUE_DISABLE);
handles.dxl_comm_result = getLastTxRxResult(handles.port_num, handles.PROTOCOL_VERSION);
handles.dxl_error = getLastRxPacketError(handles.port_num, handles.PROTOCOL_VERSION);
if handles.dxl_comm_result ~= handles.COMM_SUCCESS
    fprintf('%s\n', getTxRxResult(handles.PROTOCOL_VERSION, handles.dxl_comm_result));
elseif handles.dxl_error ~= 0
    fprintf('%s\n', getRxPacketError(handles.PROTOCOL_VERSION, handles.dxl_error));
end

% Close port
closePort(handles.port_num);

% Unload Library
unloadlibrary(handles.lib_name);

set(handles.ex1, 'enable', 'off')
set(handles.ex2, 'enable', 'off')
set(handles.ex3, 'enable', 'off')
set(handles.motor_off, 'enable', 'off')
set(handles.pushbutton1, 'enable', 'on')
set(handles.btn_color,'BackgroundColor','white');
pause (1.0);
set(handles.btn_color2,'BackgroundColor','white');
% Update handles structure
guidata(hObject, handles);
clear all;
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_color

function btn_color_Callback(hObject, eventdata, handles)
% hObject    handle to btn_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_color2.
function btn_color2_Callback(hObject, eventdata, handles)
% hObject    handle to btn_color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
