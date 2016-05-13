classdef AlexnetClassifier < Classifier
    % Classifier based on Alexnet feature-extraction.
    % Uses a linear classifier on top of the output of one of the Alexnet
    % layers.
    
    properties
        featuresLength
        netParams
        imagesMean
        classifier
    end
    
    methods
        function obj = AlexnetClassifier(featuresLength)
            obj.featuresLength = featuresLength;
            
            dir = fileparts(mfilename('fullpath'));
            obj.netParams = load([dir '/ressources/alexnetParams.mat']);
            % obtained from https://drive.google.com/file/d/0B-VdpVMYRh-pQWV1RWt5NHNQNnc/view
            imagesMeanData = load([dir '/ressources/ilsvrc_2012_mean.mat']);
            obj.imagesMean = imagesMeanData.mean_data;
        end
        
        function fit(self, features, labels)
            self.classifier = fitcecoc(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(...
                reshape(features, [size(features, 1), ...
                numel(features) / size(features, 1)]));
        end
        
        function features = extractFeatures(self, images)
            features = zeros(length(images), self.featuresLength);
            for img=1:length(images)
                preparedImage = prepareGrayscaleImage(images{img}, self.imagesMean);
                imageFeatures = self.getImageFeatures(preparedImage);
                features(img, :) = imageFeatures(:);
            end
        end
    end
    
    methods(Abstract)
        getImageFeatures(self, image, runType)
    end
end
