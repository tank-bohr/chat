-module(client).

-include_lib("wx/include/wx.hrl").

-export([
    start/0,
    message_box/1
]).

-define(FRAME_MIN_SIZE, {320, 240}).
-define(MB_SIZE, {400, 100}).
-define(DEFAULT_BORDER, {border, 10}).

start() ->
    wx:new(),
    %% Definitions
    Frame = wxFrame:new(wx:null(), ?wxID_ANY, "Chat", [
        {size, ?FRAME_MIN_SIZE}
    ]),
    ok = wxWindow:setMinSize(Frame, ?FRAME_MIN_SIZE),
    OutputText = wxTextCtrl:new(Frame, ?wxID_ANY, [
        {value, "Hello..."},
        {pos, ?wxDefaultPosition},
        {style, ?wxTE_MULTILINE bor
                ?wxTE_AUTO_URL  bor
                ?wxTE_READONLY }
    ]),
    InputText = wxTextCtrl:new(Frame, ?wxID_ANY, [
        {pos, ?wxDefaultPosition},
        {style, ?wxTE_MULTILINE bor
                ?wxTE_AUTO_URL }
    ]),
    Separator = wxStaticLine:new(Frame),
    SendBtn = wxButton:new(Frame, ?wxID_ANY, [{label, "Send"}]),
    QuitBtn = wxButton:new(Frame, ?wxID_ANY, [{label, "Quit"}]),
    %% Event handlers
    wxEvtHandler:connect(InputText, key_down, [
        {callback, fun key_down/2},
        {userData, InputText}
    ]),
    wxEvtHandler:connect(SendBtn, command_button_clicked, [
        {callback, fun send/2},
        {userData, InputText}
    ]),
    wxEvtHandler:connect(QuitBtn, command_button_clicked, [
        {callback, fun close/2},
        {userData, Frame}
    ]),
    %% Layout
    TopSizer = wxBoxSizer:new(?wxVERTICAL),
    wxSizer:add(TopSizer, OutputText, [
        {proportion, 1},
        {flag, ?wxEXPAND bor ?wxLEFT bor ?wxALL},
        ?DEFAULT_BORDER
    ]),
    wxSizer:add(TopSizer, Separator, [
        {flag, ?wxEXPAND bor ?wxLEFT bor ?wxRIGHT},
        ?DEFAULT_BORDER
    ]),
    wxSizer:add(TopSizer, InputText, [
        {proportion, 1},
        {flag, ?wxEXPAND bor ?wxLEFT bor ?wxALL},
        ?DEFAULT_BORDER
    ]),
    ButtonsSizer = wxBoxSizer:new(?wxHORIZONTAL),
    wxSizer:add(ButtonsSizer, SendBtn),
    wxSizer:add(ButtonsSizer, QuitBtn),
    wxSizer:add(TopSizer, ButtonsSizer, [
        {flag, ?wxALIGN_RIGHT bor ?wxRIGHT bor ?wxBOTTOM},
        ?DEFAULT_BORDER
    ]),
    wxWindow:setSizer(Frame, TopSizer),
    wxWindow:show(Frame),
    ok.

message_box(Text) ->
    wx:new(),
    MessageBox = wxDialog:new(wx:null(), ?wxID_ANY, "Message", [
        {size, ?MB_SIZE},
        {style, ?wxSTAY_ON_TOP bor ?wxCLOSE_BOX bor ?wxRESIZE_BORDER}
    ]),
    ok = wxWindow:setMinSize(MessageBox, ?MB_SIZE),
    Message = wxStaticText:new(MessageBox, ?wxID_ANY, Text),
    Button = wxButton:new(MessageBox, ?wxID_OK, [{label, "OK"}]),
    Sizer = wxBoxSizer:new(?wxVERTICAL),
    wxSizer:add(Sizer, Message, [
        {flag, ?wxALIGN_CENTER_HORIZONTAL bor ?wxALL},
        ?DEFAULT_BORDER
    ]),
    wxSizer:add(Sizer, Button, [
        {proportion, 1},
        {flag, ?wxALIGN_CENTER_HORIZONTAL bor ?wxALL},
        ?DEFAULT_BORDER
    ]),
    wxWindow:setSizer(MessageBox, Sizer),
    wxDialog:showModal(MessageBox).


key_down(#wx{userData = TextCtrl, event = #wxKey{
    keyCode = ?WXK_RETURN,
    shiftDown = true
}}, _Event) ->
    send(TextCtrl);
key_down(_, Event) ->
    wxEvent:skip(Event).

send(#wx{userData = TextCtrl}, _Event) ->
    send(TextCtrl).

close(#wx{userData = Frame}, _Event) ->
    wxFrame:close(Frame).

send(TextCtrl) ->
    Value = wxTextCtrl:getValue(TextCtrl),
    wxTextCtrl:clear(TextCtrl),
    message_box(Value).
