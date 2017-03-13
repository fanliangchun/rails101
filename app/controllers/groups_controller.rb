class GroupsController < ApplicationController

	before_action :find_group, only: [:edit, :update, :destroy]
	before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

	def index
		@groups = Group.all
	end

	def show
		@group = Group.find(params[:id])
		@posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 3)
	end

	def new
		@group = Group.new
	end

	def create
		@group = Group.new(group_params)
		@group.user = current_user

		if @group.save
			current_user.join!(@group)
			redirect_to groups_path
		else
			render :new
		end
	end

	def edit
	end

	def update
		if @group.update(group_params)
			redirect_to groups_path, notice: "Group Updated"
		else
			render :edit
		end
	end

	def destroy
		@group.destroy
		redirect_to groups_path, alert: "Group Deleted"
	end

	def join
		@group = Group.find(params[:id])

		if !current_user.is_member_of?(@group)
			current_user.join!(@group)
			flash[:notice] = "加入本讨论版成功"
		else
			flash[:warning] = "你已是本讨论版成员"
		end

		redirect_to group_path(@group)
		end

	def quit
		@group = Group.find(params[:id])

		if current_user.is_member_of?(@group)
			current_user.quit!(@group)
			flash[:notice] = "已成功退出讨论版"
		else
			flash[:warning] = "你不是本讨论版成员，如何退出？"
		end
		
		redirect_to group_path(@group)
	end

	private

	def group_params
		params.require(:group).permit(:title, :description)
	end

	def find_group
		@group = Group.find(params[:id])
		if current_user != @group.user
			redirect_to root_path, alert: "You have no permission."
		end
	end


end
