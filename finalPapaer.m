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


keys=twohundred_second_map.keys();
for i=1:length(keys)
    key=keys{i};
    value=twohundred_second_map(key);
    for j=1:4000
        if value.Latest_Position_m_(j)>0
            mean=(value.Latest_Position_m_(j-11)+value.Latest_Position_m_(j+11))/2;
            value.Latest_Position_m_(j)=mean;
        end
    end
    twohundred_second_map(key)=value;
end

%break into 20-50s chuncks and fit each individualy
%length of 10s=200, 20 chuncks 
%length of 20s=400, 10 chuncks
%length of 50s=1000, 4 chuncks
keys=twohundred_second_map.keys();
fitTests=containers.Map;
for i=1:length(keys)
    key=keys{i};
    value=twohundred_second_map(key);
    linearDamped=fittype(@(a0, a1, b1, w, c, x) a0+exp(-c.*x).*(a1.*sin(w*x)+b1.*cos(w.*x)));

    t0=value.Latest_Time_s_(1:400);
    p0=value.Latest_Position_m_(1:400);
    if key=="50g_200s.csv"
        [fit0, gof0, out0]=fit(t0, p0, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 5]);
    elseif key=="100g_200s.csv"
        [fit0, gof0, out0]=fit(t0, p0, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 6]);
    else
        [fit0, gof0, out0]=fit(t0, p0, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    end
    t20=value.Latest_Time_s_(400:800);
    p20=value.Latest_Position_m_(400:800);
    [fit20, gof20, out20]=fit(t20, p20, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t40=value.Latest_Time_s_(800:1200);
    p40=value.Latest_Position_m_(800:1200);
    [fit40, gof40, out40]=fit(t40, p40, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t60=value.Latest_Time_s_(1200:1600); 
    p60=value.Latest_Position_m_(1200:1600);
    [fit60, gof60, out60]=fit(t60, p60, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t80=value.Latest_Time_s_(1600:2000); 
    p80=value.Latest_Position_m_(1600:2000);
    [fit80, gof80, out80]=fit(t80, p80, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t100=value.Latest_Time_s_(2000:2400);
    p100=value.Latest_Position_m_(2000:2400);
    [fit100, gof100, out100]=fit(t100, p100, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t120=value.Latest_Time_s_(2400:2800);
    p120=value.Latest_Position_m_(2400:2800);
    [fit120, gof120, out120]=fit(t120, p120, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t140=value.Latest_Time_s_(2800:3200);
    p140=value.Latest_Position_m_(2800:3200);
    [fit140, gof140, out140]=fit(t140, p140, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .02]);
    t160=value.Latest_Time_s_(3200:3600);
    p160=value.Latest_Position_m_(3200:3600);
    [fit160, gof160, out160]=fit(t160, p160, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);
    t180=value.Latest_Time_s_(3600:4000);
    p180=value.Latest_Position_m_(3600:4000);
    [fit180, gof180, out180]=fit(t180, p180, linearDamped, "StartPoint", [-.047 .002 -.014 9.97 .01]);

    fitTests(key)={fit0 gof0 out0 fit20 gof20 out20 fit40 gof40 out40 fit60 gof60 out60 fit80 gof80 out80 fit100 gof100 out100 fit120 gof120 out120 fit140 gof140 out140 fit160 gof160 out160 fit180 gof180 out180};
end
    
    % fdrag=ma-mg-kx
fitConstantMap=containers.Map;
errorMap=containers.Map;
for i=1:length(keys)
    key=keys{i};
    value=fitTests(key);
    constants=[0 0 0 0 0 0 0 0 0 0];
    err=[0 0 0 0 0 0 0 0 0 0];
    %fprintf("\n\n%s\n", key)
    for j=1:10
        fits=value{j*3-2};
        %extract confidence intervals for c
        cint=confint(fits);
        neg=cint(1,5);
        pos=cint(2,5);
        %calculate the average 1 sigma deveation of the error
        c=fits.c;
        err(j)=(((c-neg)+(pos-c))/2)/2;
        constants(j)=c;
        %disp(fits)
    end
    fitConstantMap(key)=constants;
    errorMap(key)=err;
end

time=[0 20 40 60 80 100 120 140 160 180];
const50=fitConstantMap("50g_200s.csv");
const100=fitConstantMap("100g_200s.csv");
const200=fitConstantMap("200g_200s.csv");
const500=fitConstantMap("500g_200s.csv");

%add error bars
figure("Name", "fit constants over time for 200s");
plot(time, const50, 'o',time, const100, 'o', time, const200, 'o', time, const500, 'o');
xlabel("time (s)");
ylabel("fit constants");
title("fit constants over time for 200s trials");
legend("50g", "100g", "200g", "500g");

%plot constants with error
for i=1:length(keys)
    key=keys{i};
    figure("Name", key);
    errorbar(time, fitConstantMap(key), errorMap(key), 'o');
    xlabel("Time (s)");
    ylabel("Fit Constant");
    title("Fit Constants Over Time");
end