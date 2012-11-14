function varargout = signaldisp(varargin)
%Observe two or more signal (each signal must be in column wise) 
% SIGNALDISP M-file for signaldisp.fig
%      SIGNALDISP, by itself, creates a new SIGNALDISP or raises the existing
%      singleton*.
%
%      H = SIGNALDISP returns the handle to a new SIGNALDISP or the handle to
%      the existing singleton*.
%
%      SIGNALDISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGNALDISP.M with the given input arguments.
%
%      SIGNALDISP('Property','Value',...) creates a new SIGNALDISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before signaldisp_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to signaldisp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help signaldisp

% Last Modified by GUIDE v2.5 05-Nov-2008 12:56:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @signaldisp_OpeningFcn, ...
                   'gui_OutputFcn',  @signaldisp_OutputFcn, ...
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


% --- Executes just before signaldisp is made visible.
function signaldisp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to signaldisp (see VARARGIN)

% Choose default command line output for signaldisp
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
slider1_Callback(handles.slider1, eventdata, handles)

% UIWAIT makes signaldisp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = signaldisp_OutputFcn(hObject, eventdata, handles) 
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
if size(data,2)== 2 && ~sum(abs(diff(data(st:ed, 2))))
    line (1:(ed-st+1), data(st:ed, 1), 'color', 'b'); 
else
    line (1:(ed-st+1), data(st:ed, 1), 'color', [0.8314 0.8157 0.7843]);
end
for ln =2: size(data,2);
    cnum=ln-1;
    if size(data,2)== 2 && ~sum(abs(diff(data(st:ed, ln))))
        line (1:(ed-st+1), data(st:ed, 2), 'color', 'r');
    else
        lnpos=find(data(st:ed, ln)>0);
        if ~isempty(lnpos);
            if size(lnpos,1)==2
                line([lnpos(1) lnpos(1)], [0,100], 'color', lnclr(cnum,:));
                line([lnpos(2) lnpos(2)], [0,100], 'color', lnclr(cnum,:));
            else
                %line([1:ed-st+1], [data(st:ed, ln)], 'color', lnclr(cnum,:));
                line([lnpos lnpos], [0,100], 'color', lnclr(cnum,:));
            end;
        end
    end
end
axis tight; 
ylim(1.1*get(gca, 'ylim'));%
% for ln =1: size(data,2); 
%     cnum=1+mod((ln-1)*4+ln, size(data,2)); line (1:(ed-st+1), data(st:ed, ln), 'color', lnclr(cnum,:)); 
% end

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


