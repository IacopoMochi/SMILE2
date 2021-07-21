function toggleErrors(~,~)

h = guihandles;
if h.pb_Errors.UserData
    h.pb_Errors.String = 'Show Errors';
    h.pb_Errors.UserData = false(1);
else
    h.pb_Errors.String = 'Hide Errors';
    h.pb_Errors.UserData = true(1);
end

displayData01
    