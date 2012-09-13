module RailsAdmin
  module Config
    module Actions
      class MoveRecordsPerAssociation < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :http_methods do
          [:put]
        end

        register_instance_option :controller do
          Proc.new do
            association_name = params[:association_name].to_sym
            respond_to do |format|
              if request.put? and @object.class.reflect_on_association(association_name).try(:klass).present?
                if @object.send(association_name).update_all(@object.class.name.foreign_key => params[:new_id])
                  @object = @object.class.find(params[:new_id]) # Returning new @object and the upgraded objects
                  format.html { render :action => 'records_per_association', :layout => false }
                else
                  format.html { render :nothing => true, :status => :unprocessable_entity }
                end
              else
                format.html { render :nothing => true, :status => :forbidden }
              end
            end
          end
        end

        register_instance_option :link_icon do 
          'icon-move'
        end
      end
    end
  end

end
