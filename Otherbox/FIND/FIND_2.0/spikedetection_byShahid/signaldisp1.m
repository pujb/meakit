function varargout = signaldisp1(varargin)
%Observe two or more signal (each signal must be in column wise) 
% SIGNALDISP1 M-file for signaldisp1.fig
%      SIGNALDISP1, by itself, creates a new SIGNALDISP1 or raises the existing
%      singleton*.
% 
%      H = SIGNALDISP1 returns the handle to a new SIGNALDISP1 or the handle to
%      the existing singleton*.
%
%      SIGNALDISP1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGNALDISP1.M with the given input arguments.
%
%      SIGNALDISP1('Property','Value',...) creates a new SIGNALDISP1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before signaldisp_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to signaldisp1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help signaldisp1

% Last Modified by GUIDE v2.5 11-Nov-2008 18:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @signaldisp1_OpeningFcn, ...
                   'gui_OutputFcn',  @signaldisp1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
    pan on; pan off;
end
gcfpost=get(gcf, 'position'); 
if gcfpost(1)>.01
    gcfpost(1)=.007;
    set(gcf, 'position', gcfpost);
end
% if isfield(handles, 'sfreq'); 
%     sfreq=cell2mat(handles.sfreq); else sfreq=5000; 
% end
% set(gca, 'xlim', [0 sfreq]);
% End initialization code - DO NOT EDIT


% --- Executes just before signaldisp1 is made visible.
function signaldisp1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to signaldisp1 (see VARARGIN)

% Choose default command line output for signaldisp1
handles.output = hObject;

if size(varargin, 2)>1
    handles.data=varargin(1);
    handles.sfreq=varargin(2);
    handles.disp=cell2mat(varargin(2));
else
    handles.data=varargin;
    handles.disp=0;
end
% Update handles structure
guidata(hObject, handles);
datadisp_Callback(handles.slider1, eventdata, handles)  %slider1_Callback

% UIWAIT makes signaldisp1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = signaldisp1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data=cell2mat(handles.data);
if handles.disp>0 
    sfreq=handles.disp; 
elseif isfield(handles, 'sfreq'); 
    sfreq=cell2mat(handles.sfreq); else sfreq=length(data); 
end

%set(handles.axis1, 'ylim', [min(data(:,1)-20) max(data(:,end))+20]);
maxlen=sfreq;
xtf=get(handles.slider1, 'value');

st=floor(xtf*(length(data)-maxlen)); ed=st+maxlen; st=st+1;
if ed>length(data) 
    ed=length(data); st=ed-maxlen+1; 
end
if st<1 st=1; end
lnclr= ['k', 'b', 'r', 'g', 'c', 'm', 'y', 'b', 'r', 'g', 'c', 'm', 'y', 'b']';
cla; 
set(handles.edit1, 'string', num2str(st));
set(handles.edit2, 'string', num2str(ed))
for ln =1: size(data,2); 
    cnum=1+mod((ln-1)*4+ln, size(data,2)); line (1:(ed-st+1), data(st:ed, ln), 'color', lnclr(cnum,:)); 
end
ylim([-1 1]);
%axis tight
%for ln =1: size(data,2) line (1:(ed-st+1), data(st:ed, ln)); end
%hold on; plot(data(st:ed, :)); hold off;

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

datalen=length(cell2mat(handles.data));
stnum=str2double(get(hObject, 'string'));
if stnum<=0; stnum=1; end
if stnum>=datalen; stnum=1+datalen-5000; end
sldval=stnum/(1+datalen-5000);
set(handles.slider1, 'value', sldval);
guidata(hObject, handles);
slider1_Callback(handles.slider1, eventdata, handles)
%disp (sldval);
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

datalen=length(cell2mat(handles.data));
ednum=str2double(get(hObject, 'string'));
if ednum<=5000; ednum=5000; end
if ednum>=datalen; ednum=datalen; end
stnum=ednum-5000+1;
sldval=stnum/(1+datalen-5000);
set(handles.slider1, 'value', sldval);
guidata(hObject, handles);
slider1_Callback(handles.slider1, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function datadisp_Callback(hObject, eventdata, handles)
% hObject    handle to datadisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

datalen=length(cell2mat(handles.data));
xtf=get(hObject, 'value');
dtdisp= floor(xtf*datalen); 
if dtdisp< 5000; dtdisp=5000; end
handles.disp=dtdisp;
guidata(hObject, handles);
slider1_Callback(handles.slider1, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function datadisp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datadisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


