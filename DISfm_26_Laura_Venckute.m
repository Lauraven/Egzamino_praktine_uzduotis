clear all
clc

t=0.1:1/50:1;               % pagalbinis kintamasis
x1=sin(2*pi*t);             % 1 ivestis
x2=sin(2*pi*t/1.3);         % 2 ivestis
d1=(0.18*x1+0.8)/2;         % norimas 1 isejimo atsakas
d2=(0.3*(0.6*x2)-0.8)/2;    % norimas 2 isejimo atsakas

% pirmo sluoksnio svoriai.  w(sluoksnis)_(i neurona,is ivesties) ir b1_(neuronas)
for j = 1:3
    w1_(j,1)=randn(1);
    w1_(j,2)=randn(1);
    b1_(j)=randn(1);
end

% antro sluoksnio svoriai
w2_11=randn(1);
w2_12=randn(1);
w2_22=randn(1);
w2_23=randn(1);
b2_1=randn(1);
b2_2=randn(1);

% gristamojo rysio svoriai
w2_y1=randn(1);
w2_y2=randn(1);

%% mokymas
eta = 0.3;      % mokymo zingsnis
epoch=1000;     % epochu skaicius

for mok=1:epoch

    % y1_prev, y2_prev == y1(n-1), y2(n-1) grizatamojo rysio reiksmes
    y1_prev=0;
    y2_prev=0;

    for k=1:length(x1)
        
        %Apskaiciuojamos pirmo sluoksnio svertinos sumos
        for j = 1:3
            v1_(j)=w1_(j,1)*x1(k)+w1_(j,2)*x2(k)+b1_(j); 
            y1_(j)=v1_(j);
        end
        
        %Apskaiciuojamos antro sluoksnio svertinos sumos su gristamuoju
        %rysiu
        v2_1=y1_(1)*w2_11+y1_(2)*w2_12+y1_prev*w2_y1+b2_1;
        v2_2=y1_(2)*w2_22+y1_(3)*w2_23+y2_prev*w2_y2+b2_2;

        % tinklo isejimas
        y1(k)=tanh(v2_1);
        y2(k)=tanh(v2_2);

        % klaidos 
        e1=d1(k)-y1(k);
        e2=d2(k)-y2(k);

        %apskaiciuojami antro sluoksnio klaidos gradiantai
        % isejimo sluoksnis: delta=f(v)*e,   tanh'(v)=1-tanh(v)^2
        delta_out1=(1-tanh(v2_1)^2)*e1;
        delta_out2=(1-tanh(v2_2)^2)*e2;

        % pirmas sluoksnis: delta_j=f'(v1_j)*suma(delta_out*w2)
        % (pirmo sluoksnio aktyvacija tiesine, todel f'=1)
        delta1_1=delta_out1*w2_11;
        delta1_2=delta_out1*w2_12+delta_out2*w2_22;
        delta1_3=delta_out2*w2_23;

        %pirmo sluoksnio svoriu atnaujinimas
        w1_(1,1)=w1_(1,1)+eta*delta1_1*x1(k);
        w1_(1,2)=w1_(1,2)+eta*delta1_1*x2(k);
        b1_(1)=b1_(1)+eta*delta1_1;

        w1_(2,1)=w1_(2,1)+eta*delta1_2*x1(k);
        w1_(2,2)=w1_(2,2)+eta*delta1_2*x2(k);
        b1_(2)=b1_(2)+eta*delta1_2;

        w1_(3,1)=w1_(3,1)+eta*delta1_3*x1(k);
        w1_(3,2)=w1_(3,2)+eta*delta1_3*x2(k);
        b1_(3)=b1_(3)+eta*delta1_3;

        %antro sluoksnio svoriu atnaujinimas
        w2_11=w2_11+eta*delta_out1*y1_(1);
        w2_12=w2_12+eta*delta_out1*y1_(2);
        b2_1=b2_1+eta*delta_out1;

        w2_22=w2_22+eta*delta_out2*y1_(2);
        w2_23=w2_23+eta*delta_out2*y1_(3);
        b2_2=b2_2+eta*delta_out2;

        % gristamojo rysio svoriai (ivestis y(n-1))
        w2_y1=w2_y1+eta*delta_out1*y1_prev;
        w2_y2=w2_y2+eta*delta_out2*y2_prev;

        % atnaujinamos praeito zingsnio reiksmes kitai iteracijai
        y1_prev=y1(k);
        y2_prev=y2(k);

    end
end


% mokymo rezultatu grafikas
figure;
hold on
plot(1:length(x1), d1, 'm-o', 1:length(x1), y1, 'r*-');
plot(1:length(x2), d2, 'b-o', 1:length(x2), y2, 'g*-');
hold off
xlabel('x');
ylabel('y');
legend('Norimas atsakas (d1)', 'Apmokytas tinklo atsakas (y1)', 'Norimas atsakas (d2)', 'Apmokytas tinklo atsakas (y2)');
grid on;

%% testavimas

t_test=0.1:1/250:1;     
x1_test=sin(2*pi*t_test);
x2_test=sin(2*pi*t_test/1.3);
d1_test=(0.18*x1_test + 0.8)/2;
d2_test=(0.3*(0.6*x2_test)-0.8)/2;

% gristamojo rysio pradines reiksmes
y1_prev = 0;
y2_prev = 0;

for k = 1:length(x1_test)

    % 1 sluoksnio isejimai
    for j = 1:3
        v1_(j) = w1_(j,1)*x1_test(k) + w1_(j,2)*x2_test(k) + b1_(j);
        y1_(j)=v1_(j);
    end

    % antro sluoksnio svertines sumos su gristamuoju rysiu
    v2_1=v1_(1)*w2_11+v1_(2)*w2_12+y1_prev*w2_y1 + b2_1;
    v2_2=v1_(2)*w2_22+v1_(3)*w2_23+y2_prev*w2_y2 + b2_2;

    % tinklo isejimas
    y1_test(k)=tanh(v2_1);
    y2_test(k)=tanh(v2_2);

    % griztamasis rysys kitam zingsniui
    y1_prev = y1_test(k);
    y2_prev = y2_test(k);
end

% testavimo grafikas
figure;
hold on
plot(1:length(x1_test), d1_test, 'm-o', 1:length(x1_test), y1_test, 'r*-');
plot(1:length(x1_test), d2_test, 'b-o', 1:length(x1_test), y2_test, 'g*-');
hold off
xlabel('x');
ylabel('y');
title('Testavimas su naujomis x reiksmemis');
legend('Norimas atsakas (d1)', 'Tinklo atsakas (y1)', 'Norimas atsakas (d2)', 'Tinklo atsakas (y2)');
grid on;