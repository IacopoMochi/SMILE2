function selectImage(app)


if ~isempty(eventData.Indices)
    id  = eventData.Indices(1);
else
    id  = [];
end

app.lb_status.UserData = id;
displayData(app)