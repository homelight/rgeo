# -----------------------------------------------------------------------------
# 
# Geographic data factory implementation
# 
# -----------------------------------------------------------------------------
# Copyright 2010 Daniel Azuma
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------
;


module RGeo
  
  module Geography
    
    
    # This class implements the various factories for geography features.
    # See methods of the RGeo::Geography module for the API for creating
    # geography factories.
    
    class Factory
      
      include Features::Factory::Instance
      
      
      def initialize(namespace_, opts_={})  # :nodoc:
        @namespace = namespace_
        @opts = opts_.dup
        @projector = @namespace.const_get(:Projector).new(self, opts_) rescue nil
      end
      
      
      # Equivalence test.
      
      def eql?(rhs_)
        rhs_.is_a?(self.class) && @namespace == rhs_.instance_variable_get(:@namespace) &&
          @opts == rhs_.instance_variable_get(:@opts)
      end
      alias_method :==, :eql?
      
      
      # Returns true if this factory supports a projection.
      
      def has_projection?
        !@projector.nil?
      end
      
      
      # Returns the factory for the projected coordinate space,
      # or nil if this factory does not support a projection.
      
      def projection_factory
        @projector ? @projector.projection_factory : nil
      end
      
      
      # Projects the given geometry into the projected coordinate space,
      # and returns the projected geometry.
      # Returns nil if this factory does not support a projection.
      # Raises Errors::InvalidGeometry if the given geometry is not of
      # this factory.
      
      def project(geometry_)
        return nil unless @projector
        unless geometry_.factory == self
          raise Errors::InvalidGeometry, 'Wrong geometry type'
        end
        @projector.project(geometry_)
      end
      
      
      # Reverse-projects the given geometry from the projected coordinate
      # space into lat-long space.
      # Raises Errors::InvalidGeometry if the given geometry is not of
      # the projection defined by this factory.
      
      def unproject(geometry_)
        unless @projector && @projector.projection_factory == geometry_.factory
          raise Errors::InvalidGeometry, 'You can unproject only features that are in the projected coordinate space.'
        end
        @projector.unproject(geometry_)
      end
      
      
      # Returns true if this factory supports a projection and the
      # projection wraps its x (easting) direction. For example, a
      # Mercator projection wraps, but a local projection that is valid
      # only for a small area does not wrap.
      
      def projection_wraps?
        @projector ? @projector.wraps? : nil
      end
      
      
      # Returns a ProjectedWindow specifying the limits of the domain of
      # the projection space.
      # Returns nil if this factory does not support a projection.
      
      def projection_limits_window
        @projector ? (@projection_limits_window ||= @projector.limits_window) : nil
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkt
      
      def parse_wkt(str_)
        ImplHelpers::Serialization.parse_wkt(str_, self)
      end
      
      
      # See ::RGeo::Features::Factory#parse_wkb
      
      def parse_wkb(str_)
        ImplHelpers::Serialization.parse_wkb(str_, self)
      end
      
      
      # See ::RGeo::Features::Factory#point
      
      def point(x_, y_)
        @namespace.const_get(:PointImpl).new(self, x_, y_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line_string
      
      def line_string(points_)
        @namespace.const_get(:LineStringImpl).new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#line
      
      def line(start_, end_)
        @namespace.const_get(:LineImpl).new(self, start_, end_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#linear_ring
      
      def linear_ring(points_)
        @namespace.const_get(:LinearRingImpl).new(self, points_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#polygon
      
      def polygon(outer_ring_, inner_rings_=nil)
        @namespace.const_get(:PolygonImpl).new(self, outer_ring_, inner_rings_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#collection
      
      def collection(elems_)
        @namespace.const_get(:GeometryCollectionImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_point
      
      def multi_point(elems_)
        @namespace.const_get(:MultiPointImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_line_string
      
      def multi_line_string(elems_)
        @namespace.const_get(:MultiLineStringImpl).new(self, elems_) rescue nil
      end
      
      
      # See ::RGeo::Features::Factory#multi_polygon
      
      def multi_polygon(elems_)
        @namespace.const_get(:MultiPolygonImpl).new(self, elems_) rescue nil
      end
      
      
    end
    
  end
  
end
