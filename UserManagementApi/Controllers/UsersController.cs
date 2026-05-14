using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UserManagementApi.DTOs;
using UserManagementApi.Services;

namespace UserManagementApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        /// <summary>Get all users — Admin only</summary>
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAll()
        {
            var users = await _userService.GetAllUsersAsync();
            return Ok(users);
        }

        /// <summary>Get user by ID — Admin or own account</summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var isAdmin = User.IsInRole("Admin");

            if (!isAdmin && currentUserId != id)
                return Forbid();

            var user = await _userService.GetUserByIdAsync(id);
            if (user == null) return NotFound(new { message = "User not found." });
            return Ok(user);
        }

        /// <summary>Update user — Admin or own account</summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateUserDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var isAdmin = User.IsInRole("Admin");

            if (!isAdmin && currentUserId != id)
                return Forbid();

            var success = await _userService.UpdateUserAsync(id, dto);
            if (!success) return NotFound(new { message = "User not found or update failed." });
            return Ok(new { message = "User updated successfully." });
        }

        /// <summary>Delete user — Admin only</summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(string id)
        {
            var success = await _userService.DeleteUserAsync(id);
            if (!success) return NotFound(new { message = "User not found." });
            return Ok(new { message = "User deleted successfully." });
        }

        /// <summary>Change password — own account only</summary>
        [HttpPut("{id}/change-password")]
        public async Task<IActionResult> ChangePassword(string id, [FromBody] ChangePasswordDto dto)
        {
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (currentUserId != id) return Forbid();

            var success = await _userService.ChangePasswordAsync(id, dto);
            if (!success) return BadRequest(new { message = "Password change failed. Check current password." });
            return Ok(new { message = "Password changed successfully." });
        }

        /// <summary>Assign role to user — Admin only</summary>
        [HttpPost("assign-role")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AssignRole([FromBody] AssignRoleDto dto)
        {
            var success = await _userService.AssignRoleAsync(dto);
            if (!success) return BadRequest(new { message = "Role assignment failed." });
            return Ok(new { message = $"Role '{dto.Role}' assigned successfully." });
        }

        /// <summary>Remove role from user — Admin only</summary>
        [HttpPost("remove-role")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveRole([FromBody] AssignRoleDto dto)
        {
            var success = await _userService.RemoveRoleAsync(dto);
            if (!success) return BadRequest(new { message = "Role removal failed." });
            return Ok(new { message = $"Role '{dto.Role}' removed successfully." });
        }

        /// <summary>Get all available roles — Admin only</summary>
        [HttpGet("roles")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetRoles()
        {
            var roles = await _userService.GetAllRolesAsync();
            return Ok(roles);
        }

        /// <summary>Get current logged-in user profile</summary>
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Unauthorized();
            var user = await _userService.GetUserByIdAsync(userId);
            if (user == null) return NotFound();
            return Ok(user);
        }
    }
}
