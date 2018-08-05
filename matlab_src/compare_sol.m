function compare_sol(x, x_truth, angles1, angles2, varargin)
    x_cam=x(1:4050);
    x_cam_truth=x_truth(1:4050);
    x_pt=x(450*9+1:size(x, 1));
    x_pt_truth=x_truth(450*9+1:size(x, 1)); 
    n_pts=size(x_pt, 1)/3;
    [s R T x_pt2 ~] = absoluteOrientationQuaternion(x_pt, x_pt_truth, true);    
 %   x_pt=shapematch(x_pt_truth, x_pt);
    err1=abs(x_cam-x_cam_truth)./abs(x_cam);
    err2=abs(x_pt-x_pt_truth)./abs(x_pt_truth);
    diff=[x_pt(1:3:n_pts*3-2)-x_pt_truth(1:3:n_pts*3-2) x_pt(2:3:n_pts*3-1)-x_pt_truth(2:3:n_pts*3-1) x_pt(3:3:n_pts*3)-x_pt_truth(3:3:n_pts*3)];
    err3=sqrt(diff(:, 1).^2+diff(:, 2).^2+diff(:, 3).^2);
    clear diff;
    [~, err3_idx]=sort(err3);
    err10_idx=err3_idx(floor(n_pts*90/100):n_pts);
    err1_idx=err3_idx(floor(n_pts*99/100):n_pts);
    err01_idx=err3_idx(floor(n_pts*999/1000):n_pts);
    
    berr10_idx=err3_idx(1:floor(n_pts*10/100));
    berr1_idx=err3_idx(1:floor(n_pts*1/100));
    berr01_idx=err3_idx(1:floor(n_pts*1/1000));
    
    err10_idx2=zeros(n_pts, 1);
    for i=1:size(err10_idx)
        err10_idx2(err10_idx(i))=1;
    end
    err1_idx2=zeros(n_pts, 1);
    for i=1:size(err1_idx)
        err1_idx2(err1_idx(i))=1;
    end
    err01_idx2=zeros(n_pts, 1);
    for i=1:size(err01_idx)
        err01_idx2(err01_idx(i))=1;
    end
    angles1=angles1(berr10_idx);
    angles2=angles2(berr10_idx);
    ratio=angles1./angles2;
    hist(ratio, 50);
 %   err3=abs(x_pt2-x_pt_truth)./abs(x_pt_truth);
    fprintf('err1: %d, %d, %d, %d\n', sum(err1>0.01)*100/4050, sum(err1>0.05)*100/4050,sum(err1>0.2)*100/4050,sum(err1>1)*100/4050);    
    fprintf('err2: %d, %d, %d, %d\n', sum(err2>0.01)*100/1196061, sum(err2>0.05)*100/1196061,sum(err2>0.2)*100/1196061,sum(err2>1)*100/1196061);
  %  fprintf('err3: %d, %d, %d, %d\n', sum(err3>0.01)*100/1196061, sum(err3>0.05)*100/1196061,sum(err3>0.2)*100/1196061,sum(err3>1)*100/1196061);
  %  fprintf('%d %d\n', norm(x_pt-x_pt_truth, 2), norm(x_pt2-x_pt_truth));=
    fid=fopen(varargin{1}, 'w');        
    fprintf(fid, 'COFF\n');
    %{
    fprintf(fid, '%d %d %d\n', n_cams+n_pts, size(cam_pos, 1), size(cam_pos, 1)*3);
    for i=1:n_cams
        fprintf(fid, '%d %d %d %d %d %d %d\n', cam_pos(i, 1), cam_pos(i, 2), cam_pos(i, 3), 0, 1, 0, 1);  
        fprintf(fid, '%d %d %d %d %d %d %d\n', cam_pos(i, 1)+cam_dir(i, 1)*0.07+0.01, cam_pos(i, 2)+cam_dir(i, 2)*0.07+0.01, cam_pos(i, 3)+cam_dir(i, 3)*0.07+0.01, 0, 0.3, 0, 0.7); 
        fprintf(fid, '%d %d %d %d %d %d %d\n', cam_pos(i, 1)+cam_dir(i, 1)*0.07-0.01, cam_pos(i, 2)+cam_dir(i, 2)*0.07-0.01, cam_pos(i, 3)+cam_dir(i, 3)*0.07-0.01, 0, 0.3, 0, 0.7); 
    end
    for i=1:n_cams
        fprintf(fid, '%d %d %d %d %d %d %d %d\n', 3, i*3-3, i*3-2, i*3-1, 0, 0.5, 0, 0.7);
    end
    offset=n_cams*9;
    for i=1:n_pts
        fprintf(fid, '%d %d %d %d %d %d %d\n', x(offset+i*3-2), x(offset+i*3-1), x(offset+i*3), 0, 0, 1, 1);            
    end   
    %}
    
    fprintf(fid, '%d %d %d\n', n_pts, 0, 0);
    mean=[sum(x_pt(1:3:n_pts*3-2))/n_pts; sum(x_pt(2:3:n_pts*3-1))/n_pts; sum(x_pt(3:3:n_pts*3))/n_pts];
 %{
    for i=1:n_pts
        if err01_idx2(i)
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2)-mean(1), x_pt(i*3-1)-mean(2), x_pt(i*3)-mean(3), 1.0, 0.0, 0.0, 1.0);            
        elseif err1_idx2(i)
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2)-mean(1), x_pt(i*3-1)-mean(2), x_pt(i*3)-mean(3), 0.0, 0.0, 1.0, 1.0);            
        elseif err10_idx2(i)
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2)-mean(1), x_pt(i*3-1)-mean(2), x_pt(i*3)-mean(3), 0.0, 1.0, 0.0, 1.0);            
        else
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2)-mean(1), x_pt(i*3-1)-mean(2), x_pt(i*3)-mean(3), 1.0, 1.0, 1.0, 1.0);            
        end
    end    
 %}
    for i=1:n_pts
        if err10_idx2(i)
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2), x_pt(i*3-1), x_pt(i*3), 1.0, 0.0, 0.0, 1.0);            
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt_truth(i*3-2), x_pt_truth(i*3-1), x_pt_truth(i*3), 0.0, 1.0, 0.0, 1.0);            
        else
            fprintf(fid, '%f %f %f %f %f %f %f\n', x_pt(i*3-2), x_pt(i*3-1), x_pt(i*3), 1.0, 1.0, 1.0, 1.0);            
        end
    end
    fclose(fid);
end

% match x2 to x1 with a rotation, translation and scaling
function x3=shapematch(x1, x2)
    n_pts=size(x1, 1)/3;
    % CM of x1 and x2
    c1=[sum(x1(1:3:n_pts*3-2)); sum(x1(2:3:n_pts*3-1)); sum(x1(3:3:n_pts*3))]/n_pts;
    c2=[sum(x2(1:3:n_pts*3-2)); sum(x2(2:3:n_pts*3-1)); sum(x2(3:3:n_pts*3))]/n_pts;
    Apq=zeros(3, 3);
    Aqq=zeros(3, 3);
    for i=1:n_pts
        q=x1(i*3-2:i*3)-c1;
        p=x2(i*3-2:i*3)-c2;
        Apq=Apq+p*q';
        Aqq=Aqq+q*q';
    end
    A=Apq*inv(Aqq);
    x3=zeros(n_pts*3, 1);
    for i=1:n_pts
        x3(i*3-2:i*3)=A*(x1(i*3-2:i*3)-c1)+c2;
    end
end