clear
load all_spring_data.mat


%make new map to store the 200 second tests
twohundred_second_map=containers.Map;
%from all the spring data find the 200 second tests and store them in a new
%map
keys=allData.keys();
for i=1:length(keys)
    key=string(keys(i));
    value=allData(key);
    if size(allData(key))==[4000 4]
        twohundred_second_map(key)=value;
    end
end

%fit a function with linear damping constant
twohundred_fit=containers.Map;
keys=twohundred_second_map.keys();
for i=1:length(keys)
    key=keys{i};
    value=twohundred_second_map(key);
    damped=fittype(@(a0, a1, b1, w, c, x) a0+exp(-c.*x).*(a1.*sin(w*x)+b1.*cos(w.*x)));
    [fitline, gof, out]=fit(value.Latest_Time_s_, value.Latest_Position_m_, damped, "StartPoint", [-.047 .002 -.014 9.97 .5]);
    twohundred_fit(key)={fitline gof out};
end

%%
%plot residuals ofdamped fit
for i=1:length(keys)
    key=keys{i};
    fit=twohundred_fit(key);
    out=fit{3};
    figure("Name", key);
    plot(twohundred_second_map(key).Latest_Time_s_, out.residuals, ".");
    xlabel("time (s)");
    str="residuals of damped fit of " + extractBefore(key, "_")+" trial";
    title(str);
end

%%
for i=1:length(keys)
    key=keys{i};
    fit=twohundred_fit(key);
    funct=fit{1};
    figure("Name", key);
    plot(funct, twohundred_second_map(key).Latest_Time_s_, twohundred_second_map(key).Latest_Position_m_, "-");
    xlabel("time (s)");
    ylabel("Position (m)");
    str="data and fit of " + extractBefore(key, "_")+" trial";
    title(str);
end

%%
value=twohundred_second_map('200g_200s.csv');
t=value.Latest_Time_s_(25:625);
p=value.Latest_Position_m_(25:625);
[fitline, gof, out]=fit(t, p, damped, "StartPoint", [-.047 .002 -.014 9.97 .5]);
figure("Name", "200g 20s residuals")
plot(t, out.residuals, '.');
xlabel("Time (s)");
ylabel("residuals")
figure("Name", "200g 20s");
plot(fitline, t, p, '-');
xlabel("Time (s)");
ylabel("position");
