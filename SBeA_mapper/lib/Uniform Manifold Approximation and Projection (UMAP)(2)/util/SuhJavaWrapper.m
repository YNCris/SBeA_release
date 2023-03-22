%   AUTHORSHIP
%   Developer: Stephen Meehan <swmeehan@stanford.edu> 
%
% This class with edu.stanford.facs.matlab.Wrapper.java solves how to pass
% a MATLAB struct or object (classdef) as an argument from MATLAB to Java.
% The documentation that pointed out the direction for this solution is on
% the topic of com.mathworks.engine which starts and starts at this link.
% 
% https://www.mathworks.com/help/matlab/matlab-engine-api-for-java.html?s_tid=CRUX_lftnav
% 
% 
% The critical method needed for passing a MATLAB struct or object as an
% argument was introduced in r2021b:
% com.mathworks.engine.MatlabEngine.getCurrentMatlab
%
% Previously Java could only get a struct or object as a return value from
% MATLAB when calling MATLAB functionality from Java.... not as an argument
% into Java.
% 
% Example of passing a MATLAB struct or object argument:
% Assume the following Java
%
% package edu.stanford.facs.matlab;
% import  com.mathworks.engine.*;
% import com.mathworks.matlab.types.*;
% public class MyClass{
% public static void print(Struct s, HandleObject o) {
% //code
% }
%
% Now assume the following MATLAB commands to call this Java. First add
% the compiled Java with javaaddpath and ensure your MATLAB path includes
% this folder, <CVS>/CytoGate/matlabsrc/util.
% 
% s=struct('hi', 22, 'there', 'foobar', 'fig', figure);
% wrappedStruct=SuhJavaWrapper.Wrap(s);
% sa=StringArray({'foo', 'bar', 'dog', 'crater'});
% wrappedObject=SuhJavaWrapper.Wrap(sa);
% edu.stanford.facs.matlab.MyClass..print(wrappedStruct, wrappedObject)
% 
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
classdef SuhJavaWrapper < handle
    properties(SetAccess=private)
        wrapper;
        fields;
        id=0;
    end
    
    methods(Static)
        function this=Singleton(clear)
            persistent obj;
            if nargin>0 && clear
                obj=[];
            end
            if isempty(obj)
                obj=SuhJavaWrapper;
            else
                obj.load;
            end
            this=obj;
        end
        
        function ok=CanDo
            ok=~verLessThan('matLab', '9.11');
        end
        function value=Remove(name)
            value=SuhJavaWrapper.Singleton.remove(name);
        end

        function name=Add(value)
            name=SuhJavaWrapper.Singleton.add(value);
        end

        function obj=Wrap(value)
            obj=SuhJavaWrapper.Singleton.wrap(value);
        end
    end
    
    methods
    
        function this=SuhJavaWrapper
            this.fields=struct();
            this.load;
            if ~SuhJavaWrapper.CanDo
                warn='MATLAB r2021b or later needed to wrap() cell/structs/objects into Java.';
                warning(warn);
                try
                    msgWarning(warn);
                catch
                end
            end
            
        end

        function id=nextId(this)
            this.id=this.id+1;
            id=['F' num2str(this.id)];
        end
        
        function load(this)
            if ~isjava(this.wrapper)
                try
                    this.wrapper=edu.stanford.facs.matlab.Wrapper;
                catch ex
                    ex.getReport
                end
            end
        end
        
        function value=get(this, name)
            if isfield(this.fields, name)
                value=this.fields.(name);
            else
                value=[];
            end
        end

        function value=remove(this, name)
            if isfield(this.fields, name)
                value=this.fields.(name);
                this.fields=rmfield(this.fields, name);
            else
                value=[];
            end
        end

        function name=add(this, value)
            name=this.nextId;
            this.fields.(name)=value;
        end

        function prior=set(this, name, value)
            prior=this.get(name);
            this.fields.(name)=value;
        end
        
        function javaItem=wrap(this, matLabItem)
            name=this.add(matLabItem);
            if isstruct(matLabItem)
                javaItem=this.wrapper.getStruct(name);
            elseif isobject(matLabItem)
                javaItem=this.wrapper.getHandle(name); 
            else 
                % seems no use in CellStr conversion since 
                % marshal of cells is good since r2014a
                javaItem=matLabItem;
            end
        end
    end
end