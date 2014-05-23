function [out] = displayprogress(endvalue, string]

endvalue=100;

required_blanks=ceil(log10(endvalue))+1;
fprintf(1,[string blanks(required_blanks)]);
backspace_string=";
for n=1:required_blanks
    backspace_string=strcat(backspace_string,’\b’);
end

% build format_string: put backspaces in, define format specifier (leftalign)
format_string = [backspace_string '%-' num2str(required_blanks) 'd'];

for i=1:endvalue
    fprintf(1,format_string,i); pause(.1)
end
fprintf(‘\n’)

end